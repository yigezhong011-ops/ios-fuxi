#!/usr/bin/env python3
"""Apply every mainline patch that touches bsd_init.c (alphabetical, as the driver
does) and generate a minimal-context record-only patch."""
import shutil
import subprocess
from pathlib import Path

DEV = Path('/root/fuxi/fork-device')
XNU = Path('/root/ux3/fuxi/tree/.cache/xnu-work')
PATCHDIR = Path('/root/fuxi/uni-oldci/patches/xnu')
TARGET = 'bsd/kern/bsd_init.c'

pristine = subprocess.run(['git', '-C', str(XNU), 'show', f'HEAD:{TARGET}'],
                          capture_output=True, text=True)
if pristine.returncode:
    raise SystemExit(pristine.stderr[:300])

W = Path('/tmp/gate4')
if W.exists():
    shutil.rmtree(W)
(W / 'bsd/kern').mkdir(parents=True)
(W / TARGET).write_text(pristine.stdout)
subprocess.run(['git', 'init', '-q'], cwd=W, check=True)
subprocess.run(['git', 'add', '-A'], cwd=W, check=True)
subprocess.run(['git', '-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-qm', 'base'], cwd=W, check=True)

names = sorted(p.name for p in PATCHDIR.glob('*.patch') if TARGET in p.read_text(errors='replace'))
print('按字母顺序应用:', names)
for name in names:
    r = subprocess.run(['git', 'apply', '--whitespace=nowarn', str(PATCHDIR / name)],
                       cwd=W, capture_output=True, text=True)
    print('  %-40s %s' % (name, 'ok' if r.returncode == 0 else 'FAILED ' + (r.stderr.splitlines() or [''])[0][:60]))

post = (W / TARGET).read_text()
old = """			if (autherr && !owner_authorized) {
				panic("rootvp not authenticated after mounting");
			}"""
if old not in post:
    idx = post.find('not authenticated')
    print('上下文:', repr(post[max(0, idx - 120):idx + 60]))
    raise SystemExit('段落不匹配')

new = """			if (autherr && !owner_authorized) {
				printf("fuxi: root auth verdict %d recorded, not enforced\\n", autherr);
			}"""
(W / (TARGET + '.orig')).write_text(post)
(W / TARGET).write_text(post.replace(old, new, 1))
r = subprocess.run(['diff', '-U1', TARGET + '.orig', TARGET], cwd=W, capture_output=True, text=True)
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
print('新补丁（1 行上下文）:')
print('\n'.join(lines))

subprocess.run(['git', '-C', str(DEV), 'add', '-A'], check=False)
subprocess.run(['git', '-C', str(DEV), '-c', 'user.name=dsh', '-c', 'user.email=dsh@local',
                'commit', '-qm', 'root-auth: minimal-context record-only patch'], check=False)
p = subprocess.run(['git', '-C', str(DEV), 'push', '-q', 'origin', 'old'], capture_output=True)
print('推送:', '成功' if p.returncode == 0 else p.stderr.decode()[:150])
