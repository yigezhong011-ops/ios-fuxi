#!/usr/bin/env python3
"""Rebuild the post-mainline bsd_init.c by applying every series patch that touches
it, in series order, then generate the record-only patch against that."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
XNU = Path('/root/ux3/fuxi/tree/.cache/xnu-work')
UP = Path('/root/fuxi/uni-oldci')
PATCHDIR = UP / 'patches/xnu'
TARGET = 'bsd/kern/bsd_init.c'

pristine = subprocess.run(['git', '-C', str(XNU), 'show', f'HEAD:{TARGET}'],
                          capture_output=True, text=True)
if pristine.returncode:
    raise SystemExit(pristine.stderr[:300])

series = [l.strip() for l in (PATCHDIR / 'series').read_text().splitlines()
          if l.strip() and not l.startswith('#')]
print('系列共 %d 个补丁' % len(series))

touching = []
for name in series:
    p = PATCHDIR / name
    if not p.exists():
        continue
    text = p.read_text(errors='replace')
    if TARGET in text:
        touching.append(name)
print('改 bsd_init.c 的:', len(touching))

W = Path('/tmp/gate3')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / TARGET).write_text(pristine.stdout)
subprocess.run(['git', 'init', '-q'], cwd=W, check=True)
subprocess.run(['git', 'add', '-A'], cwd=W, check=True)
subprocess.run(['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base'], cwd=W, check=True)

applied = 0
for name in touching:
    r = subprocess.run(['git', 'apply', '--whitespace=nowarn', str(PATCHDIR / name)],
                       cwd=W, capture_output=True, text=True)
    if r.returncode == 0:
        applied += 1
    else:
        print('  跳过（上下文不匹配）:', name, r.stderr.splitlines()[:1])
print('应用了 %d 个' % applied)

post = (W / TARGET).read_text()
old = """			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}"""
if old not in post:
    print('没找到原样的 panic 段，按行定位：')
    for line in post.splitlines():
        if 'not authenticated' in line:
            print('  ', line[:130])
    raise SystemExit('请人工确认')

new = """			/* This port mounts the board's own storage without Apple's owner
			 * signing policy: record the verdict and continue to userland. */
			if (autherr && !owner_authorized) {
				printf("fuxi: root auth verdict %d recorded, not enforced\\n", autherr);
			}"""
(W / (TARGET + '.orig')).write_text(post)
(W / TARGET).write_text(post.replace(old, new, 1))
r = subprocess.run(['diff', '-u', TARGET + '.orig', TARGET], cwd=W, capture_output=True, text=True)
lines = []
for line in r.stdout.splitlines():
    if line.startswith('--- '):
        lines.append('--- a/' + TARGET)
    elif line.startswith('+++ '):
        lines.append('+++ b/' + TARGET)
    else:
        lines.append(line)
patch = DEV / 'patches/xnu/fuxi-root-auth-record-only.patch'
patch.write_text('\n'.join(lines) + '\n')
print('新补丁 %d 行:' % len(lines))
print('\n'.join(lines))
