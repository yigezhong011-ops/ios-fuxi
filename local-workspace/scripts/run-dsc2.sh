#!/bin/bash
D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
echo "== frames in stored report"
for f in /mnt/e/DSH-Fuxi/logs/crashes/*; do
  if grep -a -q 'PBFModalSceneDelegate\|PBFModalRootViewController' "$f"; then
    echo "$f"
    grep -a -o -E '"imageOffset":[0-9]+,"symbol":"[^"]{0,90}"[^}]{0,40}|\{"imageOffset":[0-9]+[^}]{0,120}' "$f" | head -6
    break
  fi
done
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-dsc-caller.py $D 2>&1 | cut -c1-170
