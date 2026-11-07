#!/usr/bin/env python3
"""Regenerate the stub patch with the owner-acceptance checkpoint the trust path
now calls."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
SRC = Path('/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')

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
    if ret == 'void':
        body = ' { }'
    else:
        body = ' { return %s; }' % (value or '0')
    lines.append('__attribute__((weak)) %s %s(%s)%s' % (ret, name, params or 'void', body))

text = SRC.read_text()
W = Path('/tmp/stubgen-final')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / 'bsd/kern/bsd_init.c').write_text(text)
(W / 'bsd/kern/bsd_init.new').write_text(text + '\n'.join(lines) + '\n')
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
print('补丁 %d 行，%d 个 stub' % (len(out), len(STUBS)))

for line in out:
    if 'checkpoint' in line or 'root_authorized' in line:
        print('  ', line[:150])

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'stubs: cover the owner-root trust path'], check=False)
p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:200])
