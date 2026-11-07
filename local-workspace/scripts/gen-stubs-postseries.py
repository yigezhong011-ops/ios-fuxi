#!/usr/bin/env python3
"""Generate the stub patch against the file as it is AFTER the mainline series: take
the patched work tree, strip our appended stubs, and diff from that."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
WORK = Path('/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')
text = WORK.read_text()
print('工作树文件 %d 行' % len(text.splitlines()))

marker = ' * Weak link stubs for the fuxi port'
idx = text.find(marker)
if idx == -1:
    raise SystemExit('工作树里没有我们的 stub 段')
# cut from the preceding comment opener
start = text.rfind('/*', 0, idx)
base = text[:start].rstrip() + '\n'
print('去掉 stub 后 %d 行，末尾:' % len(base.splitlines()))
print(repr(base[-120:]))

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

W = Path('/tmp/stubs-work')
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
print('补丁 %d 行，hunk 头:' % len(out))
for line in out[:6]:
    print('  ', line)

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'stubs: generate against the post-series file'], check=False)
p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:150])
