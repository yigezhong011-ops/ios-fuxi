#!/bin/bash
# Point the device repository's Adreno driver submodule at the fixed fork.
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git checkout -q old && git pull -q origin old

echo "=== 当前子模块配置 ==="
grep -A2 'Adreno740' .gitmodules | head -5

python3 - <<'PY'
from pathlib import Path
p = Path('.gitmodules')
t = p.read_text()
old = 'https://github.com/ljhhkx529/NativeAdreno-fuxi.git'
new = 'https://github.com/yigezhong011-ops/NativeAdreno-fuxi.git'
if new in t:
    print('已经指向 fork')
elif old in t:
    p.write_text(t.replace(old, new))
    print('已改为 fork')
else:
    print('没找到上游 URL，检查:')
    print(t[:400])
PY

git add .gitmodules
git -c user.name=dsh -c user.email=dsh@local commit -qm "submodules: use the fork whose accelerator includes the right ABI header"
git update-index --cacheinfo 160000,bb81c610759c60a065421685fad853b500d41d2a,drivers/Adreno740
git -c user.name=dsh -c user.email=dsh@local commit -qm "drivers: point Adreno740 at the fixed commit"
git push -q origin old && echo "已推送"
git ls-tree HEAD drivers/Adreno740
