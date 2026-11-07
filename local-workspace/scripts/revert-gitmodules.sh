#!/bin/bash
# Revert the submodule redirect and instead give the accelerator compile the
# AdrenoMetal include directory the source actually needs.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git checkout -q old && git pull -q origin old

python3 - <<'PY'
from pathlib import Path
p = Path('.gitmodules')
t = p.read_text()
t = t.replace('https://github.com/yigezhong011-ops/NativeAdreno-fuxi.git',
              'https://github.com/ljhhkx529/NativeAdreno-fuxi.git')
p.write_text(t)
print('已还原 .gitmodules')
PY
git add .gitmodules
git -c user.name=dsh -c user.email=dsh@local commit -qm "submodules: restore the upstream Adreno driver URL"
git push -q origin old && echo "已推送"

echo "=== accelerator 脚本在设备仓库吗 ==="
ls "$DEV/scripts" | grep -i 'adreno740-accelerator' || echo "  不在（是树里的脚本）"
