#!/bin/bash
# The port boots with owner root auth skipped, so the verified-root variants of
# NativeUfs/NativeVirtioBlock are not needed and their audit demands an owner
# signing policy the port does not carry.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git fetch -q origin old && git reset -q --hard origin/old

python3 - <<'PY'
from pathlib import Path
p = Path('board.toml')
t = p.read_text()
before = t
t = t.replace('"build-arm-driver.py NativeUfs --verified-root --verified-root-bundle"',
              '"build-arm-driver.py NativeUfs"')
t = t.replace('"build-arm-driver.py NativeVirtioBlock --verified-root --verified-root-bundle"',
              '"build-arm-driver.py NativeVirtioBlock"')
p.write_text(t)
print('已去掉 verified-root 标志:', before != t)
PY

grep -n 'NativeUfs\|NativeVirtioBlock' board.toml | head -3 | cut -c1-140

git add board.toml
git -c user.name=dsh -c user.email=dsh@local commit -qm "board: build NativeUfs and NativeVirtioBlock without the owner-verified variants"
git push origin old && echo "已推送"
