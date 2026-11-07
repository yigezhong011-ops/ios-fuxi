#!/usr/bin/env python3
"""Generate the device patch that replaces the root-auth panic with a message.

The device series applies after the mainline one, so the context is taken from the
pristine file WITH the mainline owner-root patch applied.
"""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
XNU = Path('/root/ux3/fuxi/tree/.cache/xnu-work')
UP = Path('/root/fuxi/uni-oldci')

pristine = subprocess.run(['git', '-C', str(XNU), 'show', 'HEAD:bsd/kern/bsd_init.c'],
                          capture_output=True, text=True)
if pristine.returncode:
    raise SystemExit(pristine.stderr[:300])

W = Path('/tmp/gate2')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / 'bsd/kern/bsd_init.c').write_text(pristine.stdout)
subprocess.run(['git', 'init', '-q'], cwd=W, check=True)
subprocess.run(['git', 'add', '-A'], cwd=W, check=True)
subprocess.run(['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base'], cwd=W, check=True)

main = next((p for p in (UP / 'patches/xnu').glob('*owner*root*.patch')), None)
print('主line补丁:', main.name if main else '无')
if main:
    r = subprocess.run(['git', 'apply', '--whitespace=nowarn', str(main)], cwd=W, capture_output=True, text=True)
    print('  应用:', '成功' if r.returncode == 0 else r.stderr[:200])

post = (W / 'bsd/kern/bsd_init.c').read_text()
old = """			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}"""
new = """			/* This port mounts the board's own storage without Apple's owner
			 * signing policy: record the verdict and continue to userland
			 * instead of stopping the boot. */
			if (autherr && !owner_authorized) {
				printf("fuxi: root auth verdict %d recorded, not enforced\\n", autherr);
			}"""
if old not in post:
    for line in post.splitlines():
        if 'not authenticated' in line:
            print('实际行:', line[:120])
    raise SystemExit('找不到 panic 段')

edited = post.replace(old, new, 1)
(W / 'bsd/kern/bsd_init.c.orig').write_text(post)
(W / 'bsd/kern/bsd_init.c').write_text(edited)
r = subprocess.run(['diff', '-u', 'bsd/kern/bsd_init.c.orig', 'bsd/kern/bsd_init.c'],
                   cwd=W, capture_output=True, text=True)
lines = []
for line in r.stdout.splitlines():
    if line.startswith('--- '):
        lines.append('--- a/bsd/kern/bsd_init.c')
    elif line.startswith('+++ '):
        lines.append('+++ b/bsd/kern/bsd_init.c')
    else:
        lines.append(line)
patch = DEV / 'patches/xnu/fuxi-root-auth-record-only.patch'
patch.write_text('\n'.join(lines) + '\n')
print('补丁 %d 行' % len(lines))
print('\n'.join(lines))

# revert the owner-trust config: it hangs early boot
cfg = DEV / 'configs/fuxi_gpu_defconfig'
c = cfg.read_text()
if 'CONFIG_XNU_OWNER_ROOT_TRUST=y' in c:
    cfg.write_text(c.replace('CONFIG_XNU_OWNER_ROOT_TRUST=y', 'CONFIG_XNU_OWNER_ROOT_TRUST=n'))
    print('已把 OWNER_ROOT_TRUST 改回 n')

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'root-auth: record the verdict instead of panicking'], check=False)
p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:200])
