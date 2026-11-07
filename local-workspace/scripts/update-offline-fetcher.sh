#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git pull -q origin old
cp /mnt/e/DSH-Fuxi/dump/wsl/offline-fetch-adreno3.py scripts/fetch-adreno-inputs.py
chmod +x scripts/fetch-adreno-inputs.py

# also ship the staged inputs inside the device repo path the tree can reach
mkdir -p build/adreno-inputs
cp -rn /root/fuxi/fork-device/build/adreno-inputs/* build/adreno-inputs/ 2>/dev/null || true

git add -f scripts/fetch-adreno-inputs.py build/adreno-inputs
git -c user.name=dsh -c user.email=dsh@local commit -qm "scripts: fall back to the device checkout four levels up"
git push -q origin old && echo "已推送"
echo "staged 文件数: $(find build/adreno-inputs -type f | wc -l)"
