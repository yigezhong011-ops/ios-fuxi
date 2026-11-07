#!/bin/bash
# Commit the staged inputs and the offline fetcher to the device repository.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git checkout -q old && git pull -q origin old

mkdir -p scripts
cp /mnt/e/DSH-Fuxi/dump/wsl/offline-fetch-adreno.py scripts/fetch-adreno-inputs.py
chmod +x scripts/fetch-adreno-inputs.py
echo "fetcher: $(wc -l < scripts/fetch-adreno-inputs.py) 行"
echo "staged:  $(du -sh build/adreno-inputs | cut -f1)"

git add -f build/adreno-inputs scripts/fetch-adreno-inputs.py
git -c user.name=dsh -c user.email=dsh@local commit -qm "build: stage the pinned Adreno inputs and fetch them offline"
git push -q origin old && echo "已推送"
git ls-files build/adreno-inputs | wc -l
