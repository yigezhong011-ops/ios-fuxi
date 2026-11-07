#!/usr/bin/env python3
"""Keep the patch to the appended stubs only: the EOF hunk always applies, and the
root authentication is handled by the payload's trust cache instead."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
SRC = Path('/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')

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
         ' * Weak link stubs for the fuxi port. Some of these symbols have no provider',
         ' * here at all, so they must exist in the real link as well; the force-loaded',
         ' * archives still override them.',
         ' */']
for name in NAMES:
    ret, params = TYPES.get(name, ('int', ''))
    body = ' { }' if ret == 'void' else ' { return 0; }'
    lines.append('__attribute__((weak)) %s %s(%s)%s' % (ret, name, params, body))

W = Path('/tmp/stubsonly')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
text = SRC.read_text()
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
print('补丁 %d 行（只有 EOF stub）' % len(out))

if (DEV / 'patches/xnu/fuxi-root-auth-gated.patch').exists():
    (DEV / 'patches/xnu/fuxi-root-auth-gated.patch').unlink()
    print('已删除 gate 补丁')

repo = Path('/tmp/stubcheck-ok')
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
                    'commit', '-qm', 'patches: keep only the appended stubs'], check=False)
    p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
    print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:150])
