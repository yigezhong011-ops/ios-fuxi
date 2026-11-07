#!/bin/bash
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old
cp /mnt/e/DSH-Fuxi/dump/wsl/offline-fetch-adreno4.py scripts/fetch-adreno-inputs.py
chmod +x scripts/fetch-adreno-inputs.py
grep -c 'TARGETS' scripts/fetch-adreno-inputs.py
git add -f scripts/fetch-adreno-inputs.py
git -c user.name=dsh -c user.email=dsh@local commit -q -m "scripts: fill both Adreno cache directories"
git push origin old
echo "=== 远端确认 ==="
git fetch -q origin old
git show origin/old:scripts/fetch-adreno-inputs.py | grep -n 'TARGETS\|adreno-source' | head -4
