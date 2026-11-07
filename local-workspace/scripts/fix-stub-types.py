#!/usr/bin/env python3
"""The symbols have no prototypes, so their call sites create an implicit int
declaration; the stub definitions must not declare a different return type."""
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
W = Path('/tmp/bsd-stub2')
W.mkdir(parents=True, exist_ok=True)

orig = (W / 'bsd_init.c.orig')
if not orig.exists():
    src = Path('/root/ux2/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')
    text = src.read_text()
    marker = '/*\n * UniXNU link stubs for the fuxi port'
    if marker in text:
        text = text[:text.index(marker)]
    orig.write_text(text)

STUBS = '''
/*
 * UniXNU link stubs for the fuxi port: the archives that provide these symbols
 * are built from a prelink candidate, and the candidate comes from this very
 * link, so the first link answers them here. They return int because the call
 * sites see an implicit int declaration.
 */
int sheng_pmgr_run(void) { return 0; }
int native_verified_root_probe(void) { return 0; }
int native_verified_block_volume_device(void) { return 0; }
int native_verified_block_root_authorized(void) { return 0; }
int native_gpu_addon_prepare(void) { return 0; }
int native_ram_block_gpu_addon(void) { return 0; }
int native_ram_block_volume_seed(void) { return 0; }
int native_verified_block_manifest_sha384(void) { return 0; }
int native_mobile_graphics_client_probe(void) { return 0; }
int native_owner_publish_boot_manifest(void) { return 0; }
'''
(W / 'bsd_init.c.new').write_text(orig.read_text() + STUBS)

r = subprocess.run(['diff', '-u', 'bsd_init.c.orig', 'bsd_init.c.new'], cwd=W, capture_output=True, text=True)
lines = []
for line in r.stdout.splitlines():
    if line.startswith('--- '):
        lines.append('--- a/bsd/kern/bsd_init.c')
    elif line.startswith('+++ '):
        lines.append('+++ b/bsd/kern/bsd_init.c')
    else:
        lines.append(line)
(DEV / 'patches/xnu/fuxi-link-stubs.patch').write_text('\n'.join(lines) + '\n')
print('已重写补丁，%d 行' % len(lines))

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'patches: give the link stubs the implicit int return type'], check=False)
r2 = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r2.returncode == 0 else r2.stderr.decode()[:100])
