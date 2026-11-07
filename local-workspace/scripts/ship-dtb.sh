#!/bin/bash
# The GPU prep archives need the board device tree; CI has no uefi-<board>
# checkout, so ship the DTB in the device package (which becomes kits/<kit>).
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git checkout -q old && git reset -q --hard origin/old

cp /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Resources/DTBs/fuxi.dtb package/fuxi.dtb
echo "DTB: $(stat -c%s package/fuxi.dtb) 字节"

python3 - <<'PY'
from pathlib import Path
p = Path('board.toml')
t = p.read_text()
before = t
t = t.replace('--dtb ../../../../uefi-fuxi/Resources/DTBs/fuxi.dtb',
              '--dtb kits/sheng/fuxi.dtb')
p.write_text(t)
print('替换', before.count('../../../../uefi-fuxi/Resources/DTBs/fuxi.dtb'), '处 DTB 路径')
PY

grep -n 'prepare-fuxi-gmu' board.toml | cut -c1-140

git add -f package/fuxi.dtb
git add board.toml
git -c user.name=dsh -c user.email=dsh@local commit -qm "package: ship the board device tree so the GPU prep archives run without uefi-fuxi"
git push -q origin old && echo "已推送"
