#!/usr/bin/env python3
"""Generate the stub patch against the exact bsd_init.c the tree assembly produces,
verify it with git apply --check, then commit it to the device repository."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
SRC = Path('/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')
W = Path('/tmp/stubgen')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)

text = SRC.read_text()
print('源文件 %d 行，末尾: %r' % (len(text.splitlines()), text.splitlines()[-1]))

STUBS = '''
/*
 * UniXNU link stubs for the fuxi port. The archives that provide these symbols
 * are built from a prelink candidate, and the candidate comes from this very
 * link, so the first link answers them here; the real archives replace them once
 * the candidate exists. They return int because the call sites see the implicit
 * declaration.
 */
int boot_log_tick(void) { return 0; }
int fuxi_usb_append(void) { return 0; }
int fuxi_usb_debug_start(void) { return 0; }
int native_legacy_display_late_probe(void) { return 0; }
int native_legacy_display_probe(void) { return 0; }
int native_ram_block_gpu_addon(void) { return 0; }
int native_ram_block_volume_seed(void) { return 0; }
int native_verified_block_manifest_sha384(void) { return 0; }
int native_verified_block_root_authorized(void) { return 0; }
int native_verified_block_volume_device(void) { return 0; }
int native_verified_root_probe(void) { return 0; }
int sheng_pmgr_run(void) { return 0; }
'''

(W / 'bsd/kern/bsd_init.c').write_text(text)
(W / 'bsd/kern/bsd_init.new').write_text(text + STUBS)

r = subprocess.run(['diff', '-u', 'bsd/kern/bsd_init.c', 'bsd/kern/bsd_init.new'],
                   cwd=W, capture_output=True, text=True)
lines = []
for line in r.stdout.splitlines():
    if line.startswith('--- '):
        lines.append('--- a/bsd/kern/bsd_init.c')
    elif line.startswith('+++ '):
        lines.append('+++ b/bsd/kern/bsd_init.c')
    else:
        lines.append(line)
patch_text = '\n'.join(lines) + '\n'
patch = DEV / 'patches/xnu/fuxi-link-stubs.patch'
patch.write_text(patch_text)
print('补丁 %d 行，头部: %s' % (len(lines), lines[2] if len(lines) > 2 else ''))

# verify inside a throwaway git repo
repo = Path('/tmp/stubcheck')
if repo.exists():
    shutil.rmtree(repo)
(repo / 'bsd/kern').mkdir(parents=True)
shutil.copy(SRC, repo / 'bsd/kern/bsd_init.c')
subprocess.run(['git', 'init', '-q'], cwd=repo, check=True)
subprocess.run(['git', 'add', '-A'], cwd=repo, check=True)
subprocess.run(['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base'], cwd=repo, check=True)
check = subprocess.run(['git', 'apply', '--check', str(patch)], cwd=repo, capture_output=True, text=True)
print('apply --check:', '通过' if check.returncode == 0 else check.stderr[:200])

if check.returncode == 0:
    subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
    subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                    'commit', '-qm', 'patches: append the fuxi link stubs to bsd_init.c'], check=False)
    p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
    print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:120])
