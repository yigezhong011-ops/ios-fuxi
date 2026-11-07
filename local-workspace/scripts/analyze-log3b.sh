#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon3/boot.log
echo "=== 行数 ==="; wc -l "$L"
echo
echo "=== 关键节点 ==="
grep -a -nE 'root file in userdata|exec launchd$|exec SpringBoard|exec backboardd|panic|IOFindBSDRoot' "$L" | head -20
echo
echo "=== P-SYS / 权限 ==="
grep -a -nE 'fuxiprivs|fuxisbpath|privilege [0-9]+ granted|DARKBOOT' "$L" | head -20
echo
echo "=== SpringBoard 全部 ==="
grep -a -n 'SpringBoard' "$L" | head -20
echo
echo "=== 最后 25 行 ==="
tail -c 4000 "$L" | tr -d '\000' | tail -25
