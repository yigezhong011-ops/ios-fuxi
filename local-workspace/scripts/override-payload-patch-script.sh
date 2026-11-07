#!/bin/bash
# The payload patch compiles the panic screen and needs the UEFI Font.h; the tree
# is rebuilt before the payload step, so point the script at the device copy.
set -euo pipefail
DEV=/root/fuxi/fork-device
T=/root/ux3/fuxi/tree
cd "$DEV"
git fetch -q origin old
git reset -q --hard origin/old

cp "$T/scripts/patch-xnu-entry-probe.py" scripts/patch-xnu-entry-probe.py

python3 - <<'PY'
from pathlib import Path
p = Path('scripts/patch-xnu-entry-probe.py')
t = p.read_text()
if 'UNIXNU_UEFI' in t and 'setdefault' in t:
    print('已经改过')
else:
    head = ('import os as _os\n'
            'from pathlib import Path as _Path\n'
            '# The payload step needs the UEFI frame-buffer font; keep it in the device\n'
            '# repository because the tree is rebuilt before this runs.\n'
            '_os.environ.setdefault("UNIXNU_UEFI", str(_Path(__file__).resolve().parents[1] / "uefi-fonts"))\n')
    t = head + t
    p.write_text(t)
    print('已注入 UNIXNU_UEFI 默认值')
PY

head -4 scripts/patch-xnu-entry-probe.py

git add -f scripts/patch-xnu-entry-probe.py
git -c user.name=dsh -c user.email=dsh@local commit -q -m "scripts: point the payload patch at the device copy of the UEFI font"
git push -q origin old
echo "已推送"
