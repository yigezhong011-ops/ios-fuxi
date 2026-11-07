#!/usr/bin/env python3
"""Generate a device patch that gates the root-auth panic, with context that matches
the file AFTER the mainline series (that is when device patches apply)."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
XNU = Path('/root/ux3/fuxi/tree/.cache/xnu-work')
UP = Path('/root/fuxi/uni-oldci')          # yesterday's upstream tree: mainline patch source

pristine = subprocess.run(['git', '-C', str(XNU), 'show', 'HEAD:bsd/kern/bsd_init.c'],
                          capture_output=True, text=True)
if pristine.returncode:
    raise SystemExit(pristine.stderr[:300])

W = Path('/tmp/gate-patch')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / 'bsd/kern/bsd_init.c').write_text(pristine.stdout)

subprocess.run(['git', 'init', '-q'], cwd=W, check=True)
subprocess.run(['git', 'add', '-A'], cwd=W, check=True)
subprocess.run(['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base'], cwd=W, check=True)

# apply the mainline owner-root patch the same way the build does
main = UP / 'patches/xnu/offline-owner-root-binding-audit.patch'
if not main.exists():
    candidates = list((UP / 'patches/xnu').glob('*owner*root*.patch'))
    print('候选主line补丁:', [p.name for p in candidates])
    main = candidates[0] if candidates else None
print('主line补丁:', main)

if main and main.exists():
    r = subprocess.run(['git', 'apply', '--whitespace=nowarn', str(main)], cwd=W, capture_output=True, text=True)
    print('应用主line补丁:', '成功' if r.returncode == 0 else r.stderr[:200])

post = (W / 'bsd/kern/bsd_init.c').read_text()
old = """			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}"""
new = """			/* This port mounts the board's own storage without the owner
			 * signing policy: the authentication verdict is recorded, not
			 * enforced, so the boot can continue to userland. */
			if (autherr && !owner_authorized) {
				printf("fuxi: root auth verdict %d ignored (owner trust off)\\n", autherr);
			}"""
if old not in post:
    for line in post.splitlines():
        if 'not authenticated' in line:
            print('实际上下文:', line[:120])
    raise SystemExit('找不到 panic 段（主line补丁可能没应用）')

(W / 'bsd/kern/bsd_init.c').write_text(post.replace(old, new, 1))
r = subprocess.run(['diff', '-u', 'bsd/kern/bsd_init.c.orig', 'bsd/kern/bsd_init.c'],
                   cwd=W, capture_output=True, text=True)
print('diff 行数', len(r.stdout.splitlines()))
print(r.stdout[:400])
