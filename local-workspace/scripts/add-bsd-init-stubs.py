#!/usr/bin/env python3
"""Append the link stubs to bsd_init.c through the patch series: the board's
archives that would provide them need a prelink candidate, which cannot exist
before the first link, so the first link answers them locally."""
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
SRC = Path('/root/ux2/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')
W = Path('/tmp/bsd-stub')
W.mkdir(parents=True, exist_ok=True)

orig = SRC.read_text()
STUBS = '''

/*
 * UniXNU link stubs for the fuxi port: the archives that provide these symbols
 * are built from a prelink candidate, and the candidate comes from this very
 * link, so the first link answers them here. The real archives replace them in
 * a full build.
 */
void sheng_pmgr_run(void) {}
void native_verified_root_probe(void) {}
void native_verified_block_volume_device(void) {}
void native_verified_block_root_authorized(void) {}
void native_gpu_addon_prepare(void) {}
void native_ram_block_gpu_addon(void) {}
void native_ram_block_volume_seed(void) {}
void native_verified_block_manifest_sha384(void) {}
void native_mobile_graphics_client_probe(void) {}
void native_owner_publish_boot_manifest(void) {}
'''
if 'UniXNU link stubs for the fuxi port' in orig:
    print('已经加过')
else:
    (W / 'bsd_init.c.orig').write_text(orig)
    (W / 'bsd_init.c.new').write_text(orig + STUBS)
    print('已追加 stub 定义')

    r = subprocess.run(['diff', '-u', 'bsd_init.c.orig', 'bsd_init.c.new'],
                       cwd=W, capture_output=True, text=True)
    lines = []
    for line in r.stdout.splitlines():
        if line.startswith('--- '):
            lines.append('--- a/bsd/kern/bsd_init.c')
        elif line.startswith('+++ '):
            lines.append('+++ b/bsd/kern/bsd_init.c')
        else:
            lines.append(line)
    patch = DEV / 'patches/xnu/fuxi-link-stubs.patch'
    patch.write_text('\n'.join(lines) + '\n')
    print('补丁:', patch, len(lines), '行')

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'patches: answer the fuxi link symbols before the first prelink'],
               check=False)
r = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if r.returncode == 0 else r.stderr.decode()[:100])
