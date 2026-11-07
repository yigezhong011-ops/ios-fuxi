#!/usr/bin/env python3
"""Merge the root-auth gate into the stub patch: two patches against the same file
in the same series conflict."""
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

text = SRC.read_text()

# 1) gate the panic
old = """			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}"""
new = """#if defined(XNU_OWNER_ROOT_TRUST) && XNU_OWNER_ROOT_TRUST
			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}
#else
			/* This port runs without owner-root verification: record the mount's
			 * authentication verdict instead of enforcing it. */
			(void)autherr;
			(void)owner_authorized;
#endif"""
if old not in text:
    raise SystemExit('找不到 panic 段（可能已打过）')
text = text.replace(old, new, 1)

# 2) append the weak stubs
stub_lines = ['', '/*',
              ' * Weak link stubs for the fuxi port. Some of these symbols have no',
              ' * provider here at all, so they must exist in the real link as well;',
              ' * force-loaded archives still override them.',
              ' */']
for name in NAMES:
    ret, params = TYPES.get(name, ('int', ''))
    body = ' { }' if ret == 'void' else ' { return 0; }'
    stub_lines.append('__attribute__((weak)) %s %s(%s)%s' % (ret, name, params, body))
text = text + '\n'.join(stub_lines) + '\n'

W = Path('/tmp/merged-patch')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / 'bsd/kern/bsd_init.c').write_text(SRC.read_text())
(W / 'bsd/kern/bsd_init.new').write_text(text)
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
merged = DEV / 'patches/xnu/fuxi-link-stubs.patch'
merged.write_text('\n'.join(out) + '\n')
print('合并补丁 %d 行' % len(out))

sep = DEV / 'patches/xnu/fuxi-root-auth-gated.patch'
if sep.exists():
    sep.unlink()
    print('已删除单独的 root-auth 补丁')

repo = Path('/tmp/merged-check')
if repo.exists():
    shutil.rmtree(repo)
(repo / 'bsd/kern').mkdir(parents=True)
shutil.copy(SRC, repo / 'bsd/kern/bsd_init.c')
for cmd in (['git', 'init', '-q'], ['git', 'add', '-A'],
            ['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base']):
    subprocess.run(cmd, cwd=repo, check=True)
chk = subprocess.run(['git', 'apply', '--check', str(merged)], cwd=repo, capture_output=True, text=True)
print('apply --check:', '通过' if chk.returncode == 0 else chk.stderr[:200])

if chk.returncode == 0:
    subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
    subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                    'commit', '-qm', 'patches: merge the root-auth gate into the stub patch'], check=False)
    p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
    print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:150])
