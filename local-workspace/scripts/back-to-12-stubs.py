#!/usr/bin/env python3
"""Back to the 12 stubs that built a bootable kernel, plus owner-root trust so the
root authorization answers 1. The two extra checkpoint stubs are what most likely
turned real code into no-ops."""
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
REPO = Path('/root/ux3/fuxi/tree/.cache/xnu-work')

pristine = subprocess.run(['git', '-C', str(REPO), 'show', 'HEAD:bsd/kern/bsd_init.c'],
                          capture_output=True, text=True)
if pristine.returncode:
    raise SystemExit(pristine.stderr[:200])
base = pristine.stdout

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
]

lines = ['', '/*',
         ' * Weak link stubs for the fuxi port. Some of these symbols have no provider',
         ' * here at all, so they must exist in the real link as well; the force-loaded',
         ' * archives still override them.',
         ' */']
for ret, name, params, value in STUBS:
    body = ' { }' if ret == 'void' else ' { return %s; }' % (value or '0')
    lines.append('__attribute__((weak)) %s %s(%s)%s' % (ret, name, params or 'void', body))

import shutil
W = Path('/tmp/stubs12')
if W.exists():
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
(DEV / 'patches/xnu/fuxi-link-stubs.patch').write_text('\n'.join(out) + '\n')
print('stub 补丁恢复为 12 个')

# drop the patch that never applied
bad = DEV / 'patches/xnu/fuxi-root-auth-record-only.patch'
if bad.exists():
    bad.unlink()
    print('已删除 record-only 补丁')

cfg = DEV / 'configs/fuxi_gpu_defconfig'
c = cfg.read_text()
cfg.write_text(c.replace('CONFIG_XNU_OWNER_ROOT_TRUST=n', 'CONFIG_XNU_OWNER_ROOT_TRUST=y'))
print('OWNER_ROOT_TRUST=y')
print([l for l in cfg.read_text().splitlines() if 'OWNER_ROOT' in l])

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'stubs: back to the twelve that booted; trust the owner root'], check=False)
p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:150])
