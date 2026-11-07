#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon3/boot.log
echo "=== 行数 ==="; wc -l "$L"
echo
echo "=== P-SYS 开关是否生效 ==="
grep -nE 'fuxiprivs|fuxisbpath|privilege .* granted|DARKBOOT|1007' "$L" | head -20
echo
echo "=== SpringBoard 相关 ==="
grep -n 'SpringBoard' "$L" | head -15
echo
echo "=== 关键节点 ==="
grep -nE 'root file in userdata|exec launchd$|exec SpringBoard|exec backboardd|panic' "$L" | head -15
echo
echo "=== 最后 30 行 ==="
tail -n 30 "$L"
