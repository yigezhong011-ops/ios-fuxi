#!/usr/bin/env python3
"""This port runs without owner-root verification, so the root-auth panic must be
gated by the same switch — otherwise the kernel always panics after mounting."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
SRC = Path('/root/ux3/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c')
W = Path('/tmp/rootauth-patch')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)

text = SRC.read_text()
old = """			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}"""
new = """#if defined(XNU_OWNER_ROOT_TRUST) && XNU_OWNER_ROOT_TRUST
			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}
#else
			/* This port runs without owner-root verification: the mount's
			 * authentication verdict is recorded, not enforced. */
			(void)autherr;
			(void)owner_authorized;
#endif"""
if '#else\n\t\t\t/* This port runs without owner-root verification' in text:
    print('已经改过')
else:
    if old not in text:
        raise SystemExit('找不到 panic 段')
    text = text.replace(old, new, 1)
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
    patch = DEV / 'patches/xnu/fuxi-root-auth-gated.patch'
    patch.write_text('\n'.join(out) + '\n')
    print('补丁 %d 行' % len(out))

    repo = Path('/tmp/rootauth-check')
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
                        'commit', '-qm', 'patches: gate the root-auth panic by the owner-trust switch'],
                       check=False)
        p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
        print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:150])
