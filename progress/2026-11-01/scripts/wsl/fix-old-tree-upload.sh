#!/bin/bash
# unixnu-ci branch old-tree: the old upstream writes out/<board>/kernel and out/<board>/payload (two levels),
# not the three-level layout of the newer upstream the upload steps were written for.
set -euo pipefail
cd /root/fuxi/uni-oldci
python3 - <<'PY'
from pathlib import Path
p = Path('.github/workflows/macos.yml')
t = p.read_text()
for old, new in (('out/*/*/*/kernel/kernel.macho', 'out/*/kernel/kernel.macho'),
                 ('out/*/*/*/kernel/kernel.json', 'out/*/kernel/kernel.json'),
                 ('out/*/*/*/payload/payload.img', 'out/*/payload/payload.img')):
    assert t.count(old) == 1, old
    t = t.replace(old, new)
p.write_text(t)
PY
git -c user.name=dsh -c user.email=dsh@local commit -qam "ci: upload paths of the two-level out/ layout"
git push -q ci HEAD:refs/heads/old-tree
git log --oneline -2
