#!/bin/bash
# Fork the Adreno driver, fix the stale include path, and point the device
# repository at the fork.
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/drv-fork
rm -rf "$W"
git clone -q "https://x-access-token:${TOKEN}@github.com/ljhhkx529/NativeAdreno-fuxi.git" "$W"
cd "$W" || exit 1
git log --oneline -1

python3 - <<'PY'
from pathlib import Path
p = Path('NativeAdrenoAccelerator.cpp')
t = p.read_text()
old = '#include "../NativeMetal/OriginalAcceleratorABI.h"'
new = '#include "../AdrenoMetal/OriginalAcceleratorABI.h"'
if new in t:
    print('已经改过')
elif old in t:
    p.write_text(t.replace(old, new, 1))
    print('已修正 include 路径')
else:
    raise SystemExit('找不到 include 行')
PY

git -c user.name=dsh -c user.email=dsh@local commit -qam "accelerator: include the ABI header from AdrenoMetal"
git remote set-url origin "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/NativeAdreno-fuxi.git"
git push -q -u origin HEAD:main 2>&1 | tail -2 && echo "已推送到 yigezhong011-ops/NativeAdreno-fuxi"
git rev-parse HEAD
