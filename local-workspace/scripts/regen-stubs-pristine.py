#!/usr/bin/env python3
"""Regenerate the stub patch from the pristine file in the xnu work tree."""
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
REPO = Path('/root/ux3/fuxi/tree/.cache/xnu-work')

pristine = subprocess.run(['git', '-C', str(REPO), 'show', 'HEAD:bsd/kern/bsd_init.c'],
                          capture_output=True, text=True)
if pristine.returncode != 0:
    raise SystemExit('取不到原始文件: ' + pristine.stderr[:200])
base = pristine.stdout
print('原始文件 %d 行' % len(base.splitlines()))

STUBS = [
    ('void', 'boot_log_tick', 'int', ''),
    ('void', 'fuxi_usb_append', 'const char *, uint32_t', ''),
    ('void', 'fuxi_usb_debug_start', 'void', ''),
    ('void', 'native_legacy_display_late_probe', 'void', ''),
    ('void', 'native_legacy_display_probe', 'void', ''),
    ('int', 'native_ram_block_gpu_addon', 'const uint8_t **, uint64_t *', ''),
    ('int', 'native_ram_block_volume_seed', 'const char *, dev_t *, char *, size_t, uint64_t *, uint64_t *, uint8_t *', ''),
    ('void', 'native_verified_block_manifest_sha384', 'uint8_t *', ''),
    ('int', 'native_verified_block_root_authorized', 'dev_t', '1'),
    ('int', 'native_verified_block_volume_device', 'const char *, dev_t *, char *, size_t', ''),
    ('void', 'native_verified_root_probe', 'void', ''),
    ('void', 'sheng_pmgr_run', 'void', ''),
    ('void', 'native_owner_root_accepted_checkpoint', 'int, int', ''),
    ('void', 'native_owner_root_checkpoint', 'int, int, dev_t', ''),
]

lines = ['', '/*',
         ' * Weak link stubs for the fuxi port. Some of these symbols have no provider',
         ' * here at all, so they must exist in the real link as well; the force-loaded',
         ' * archives still override them.',
         ' */']
for ret, name, params, value in STUBS:
    body = ' { }' if ret == 'void' else ' { return %s; }' % (value or '0')
    lines.append('__attribute__((weak)) %s %s(%s)%s' % (ret, name, params or 'void', body))

W = Path('/tmp/pristine-stubs')
if W.exists():
    import shutil
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / 'bsd/kern/bsd_init.c').write_text(base)
(W / 'bsd/kern/bsd_init.new').write_text(base + '\n'.join(lines) + '\n')
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
print('新补丁 %d 行，只有 EOF 一个 hunk' % len(out))
print('\n'.join(out[:6]))
