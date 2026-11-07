#!/usr/bin/env python3
"""Revert the bootstrap guard: some of these symbols have no archive provider at
all, so the weak stubs must exist in the real link too (force_load archives still
override them)."""
import shutil
import subprocess
from pathlib import Path

TREE = Path('/root/ux3/fuxi/tree')
SRC = TREE / '.cache/xnu-work/bsd/kern/bsd_init.c'
DEV = Path('/root/fuxi/fork-device')

NAMES = ['boot_log_tick', 'fuxi_usb_append', 'fuxi_usb_debug_start',
         'native_legacy_display_late_probe', 'native_legacy_display_probe',
         'native_ram_block_gpu_addon', 'native_ram_block_volume_seed',
         'native_verified_block_manifest_sha384', 'native_verified_block_root_authorized',
         'native_verified_block_volume_device', 'native_verified_root_probe',
         'sheng_pmgr_run']

TYPES = {
    'fuxi_usb_debug_start': ('void', 'void'),
    'native_legacy_display_late_probe': ('void', 'void'),
    'native_legacy_display_probe': ('void', 'void'),
    'native_verified_root_probe': ('void', 'void'),
    'sheng_pmgr_run': ('void', 'void'),
    'native_verified_block_root_authorized': ('int', 'dev_t'),
    'native_ram_block_gpu_addon': ('int', 'const uint8_t **, uint64_t *'),
    'native_ram_block_volume_seed': ('int', 'const char *, dev_t *, char *, size_t, uint64_t *, uint64_t *, uint8_t *'),
    'native_verified_block_volume_device': ('int', 'const char *, dev_t *, char *, size_t'),
}

lines = ['', '/*',
         ' * Weak link stubs for the fuxi port. Some of these symbols have no',
         ' * provider in this port at all, so they must exist in the real link as',
         ' * well; the archives that are force-loaded still override them.',
         ' */']
for name in NAMES:
    ret, params = TYPES.get(name, ('int', ''))
    body = ' { }' if ret == 'void' else ' { return 0; }'
    lines.append('__attribute__((weak)) %s %s(%s)%s' % (ret, name, params, body))
STUBS = '\n'.join(lines) + '\n'

W = Path('/tmp/stubgenA')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
text = SRC.read_text()
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
(DEV / 'patches/xnu/fuxi-link-stubs.patch').write_text('\n'.join(out) + '\n')
print('补丁 %d 行' % len(out))

repo = Path('/tmp/stubcheckA')
if repo.exists():
    shutil.rmtree(repo)
(repo / 'bsd/kern').mkdir(parents=True)
shutil.copy(SRC, repo / 'bsd/kern/bsd_init.c')
for cmd in (['git', 'init', '-q'], ['git', 'add', '-A'],
            ['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base']):
    subprocess.run(cmd, cwd=repo, check=True)
chk = subprocess.run(['git', 'apply', '--check', str(DEV / 'patches/xnu/fuxi-link-stubs.patch')],
                     cwd=repo, capture_output=True, text=True)
print('apply --check:', '通过' if chk.returncode == 0 else chk.stderr[:160])

if chk.returncode == 0:
    subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
    subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                    'commit', '-qm', 'patches: keep the weak stubs in every link'], check=False)
    p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
    print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:120])
