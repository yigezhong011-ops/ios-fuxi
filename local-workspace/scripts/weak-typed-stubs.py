#!/usr/bin/env python3
"""Same typed stubs as before, but weak so the real archives win the final link."""
import re
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

decls = {}
pat = re.compile(r'extern\s+([A-Za-z_][\w \*]*?)\s+(' + '|'.join(NAMES) + r')\s*\(([^;]*)\)\s*;')
for root in (TREE / '.cache/xnu-work/bsd/kern', TREE / '.cache/xnu-work/iokit', TREE / 'kits'):
    for path in root.rglob('*'):
        if path.suffix not in ('.c', '.cpp', '.h', '.hpp', '.cpo'):
            continue
        try:
            text = path.read_text(errors='replace')
        except OSError:
            continue
        for m in pat.finditer(text):
            decls.setdefault(m.group(2), (m.group(1).strip(), m.group(3).strip()))

lines = ['\n/*',
         ' * Weak link stubs for the fuxi port: the archives that provide these symbols',
         ' * are built after the first link, so the bootstrap link answers them here and',
         ' * their strong definitions take precedence once they are linked.',
         ' */']
for name in NAMES:
    ret, params = decls.get(name, ('int', ''))
    ret = ret.replace('static ', '').strip()
    body = ' { }' if ret == 'void' else ' { return 0; }'
    lines.append('__attribute__((weak)) %s %s(%s)%s' % (ret, name, params, body))
STUBS = '\n'.join(lines) + '\n'

W = Path('/tmp/stubgen8')
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
patch = DEV / 'patches/xnu/fuxi-link-stubs.patch'
patch.write_text('\n'.join(out) + '\n')
print('补丁 %d 行' % len(out))

repo = Path('/tmp/stubcheck8')
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
                    'commit', '-qm', 'patches: typed weak stubs for the bootstrap link'], check=False)
    p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
    print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:120])
