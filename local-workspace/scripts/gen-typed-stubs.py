#!/usr/bin/env python3
"""Generate stub definitions that match the block-scope extern declarations the
patched kernel sources actually contain."""
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

# collect `extern <ret> name(<params>);` declarations across the tree sources
decls = {}
pat = re.compile(r'extern\s+([A-Za-z_][\w \*]*?)\s+(' + '|'.join(NAMES) + r')\s*\(([^;]*)\)\s*;')
roots = [TREE / '.cache/xnu-work/bsd/kern', TREE / '.cache/xnu-work/iokit', TREE / 'kits']
for root in roots:
    for path in root.rglob('*'):
        if path.suffix not in ('.c', '.cpp', '.h', '.hpp', '.cpo'):
            continue
        try:
            text = path.read_text(errors='replace')
        except OSError:
            continue
        for m in pat.finditer(text):
            ret, name, params = m.group(1).strip(), m.group(2), m.group(3).strip()
            decls.setdefault(name, (ret, params))

print('找到的声明:')
for name in NAMES:
    print('  %-38s %s' % (name, decls.get(name, '（无声明，用隐式 int）')))

lines = ['\n/*',
         ' * UniXNU link stubs for the fuxi port: the archives that provide these',
         ' * symbols are built from a prelink candidate, and the candidate comes from',
         ' * this very link, so the first link answers them here. Each definition',
         ' * matches the declaration the caller in this tree uses.',
         ' */']
for name in NAMES:
    ret, params = decls.get(name, ('int', ''))
    ret = ret.replace('static ', '').strip()
    if ret == 'void':
        lines.append('void %s(%s) { }' % (name, params))
    else:
        lines.append('%s %s(%s) { return 0; }' % (ret, name, params))
STUBS = '\n'.join(lines) + '\n'

W = Path('/tmp/stubgen3')
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
print('\n补丁 %d 行' % len(out))

repo = Path('/tmp/stubcheck3')
if repo.exists():
    shutil.rmtree(repo)
(repo / 'bsd/kern').mkdir(parents=True)
shutil.copy(SRC, repo / 'bsd/kern/bsd_init.c')
for cmd in (['git', 'init', '-q'], ['git', 'add', '-A'],
            ['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base']):
    subprocess.run(cmd, cwd=repo, check=True)
chk = subprocess.run(['git', 'apply', '--check', str(patch)], cwd=repo, capture_output=True, text=True)
print('apply --check:', '通过' if chk.returncode == 0 else chk.stderr[:200])

if chk.returncode == 0:
    subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
    subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                    'commit', '-qm', 'patches: match each link stub to its declaration'], check=False)
    p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
    print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:120])
