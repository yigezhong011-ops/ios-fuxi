#!/usr/bin/env python3
"""Wrap the bsd_init.c link stubs in #if XNU_BOOTSTRAP so they disappear from the
real link and the board archives provide those symbols."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
SRC = Path('/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')
text = SRC.read_text()

NAMES = ['boot_log_tick', 'fuxi_usb_append', 'fuxi_usb_debug_start',
         'native_legacy_display_late_probe', 'native_legacy_display_probe',
         'native_ram_block_gpu_addon', 'native_ram_block_volume_seed',
         'native_verified_block_manifest_sha384', 'native_verified_block_root_authorized',
         'native_verified_block_volume_device', 'native_verified_root_probe',
         'sheng_pmgr_run']

# types as the call sites declare them
TYPES = {
    'fuxi_usb_debug_start': ('void', 'void'),
    'native_legacy_display_late_probe': ('void', 'void'),
    'native_legacy_display_probe': ('void', 'void'),
    'native_verified_root_probe': ('void', 'void'),
    'sheng_pmgr_run': ('void', 'void'),
    'native_verified_block_root_authorized': ('int', 'dev_t'),
}

lines = ['', '#if defined(XNU_BOOTSTRAP) && XNU_BOOTSTRAP',
         '/*',
         ' * Link stubs for the bootstrap pass only: the archives that provide these',
         ' * symbols are built after the first link. The define keeps them out of the',
         ' * real link, where the archives must win.',
         ' */']
for name in NAMES:
    ret, params = TYPES.get(name, ('int', ''))
    body = ' { }' if ret == 'void' else ' { return 0; }'
    lines.append('%s %s(%s)%s' % (ret, name, params, body))
lines.append('#endif /* XNU_BOOTSTRAP */')
STUBS = '\n'.join(lines) + '\n'

W = Path('/tmp/stubgen9')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / 'bsd/kern/bsd_init.c').write_text(text)
(W / 'bsd/kern/bsd_init.new').write_text(text + STUBS)
r = subprocess.run(['diff', '-u', 'bsd/kern/bsd_init.c', 'bsd/kern/bsd_init.new'],
                   cwd=W, capture_output=True, text=True)
out = []
for line in r.stdout.splitlines():
    if line.startswith('--- '):
        out.append('--- a/bsd/kern/bsd_init.c')
    elif line.startswith('+++ '):
        out.append('+++ b/bsd/kern/bsd_init.c')
    else:
        out.append(line)
patch = DEV / 'patches/xnu/fuxi-link-stubs.patch'
patch.write_text('\n'.join(out) + '\n')
print('补丁 %d 行' % len(out))

repo = Path('/tmp/stubcheck9')
if repo.exists():
    shutil.rmtree(repo)
(repo / 'bsd/kern').mkdir(parents=True)
shutil.copy(SRC, repo / 'bsd/kern/bsd_init.c')
for cmd in (['git', 'init', '-q'], ['git', 'add', '-A'],
            ['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base']):
    subprocess.run(cmd, cwd=repo, check=True)
chk = subprocess.run(['git', 'apply', '--check', str(patch)], cwd=repo, capture_output=True, text=True)
print('apply --check:', '通过' if chk.returncode == 0 else chk.stderr[:160])

if chk.returncode == 0:
    subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
    subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                    'commit', '-qm', 'patches: keep the link stubs inside the bootstrap define'], check=False)
    p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
    print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:120])
