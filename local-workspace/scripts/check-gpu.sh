#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon5/boot.log
echo "=== GPU 相关 ==="
grep -a -n 'GPU' "$L" | head -40 || echo "(no GPU lines)"
echo
echo "=== 关键节点 ==="
grep -a -nE 'root file in userdata|exec launchd$|exec SpringBoard|exec backboardd' "$L" | head -10
echo
echo "=== 末尾 20 行 ==="
tail -c 3000 "$L" | tr -d '\000' | tail -20
