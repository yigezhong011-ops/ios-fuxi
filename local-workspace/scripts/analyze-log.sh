#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon/boot.log
echo "=== 行数 / 大小 ==="
wc -l "$L"; wc -c "$L"
echo
echo "=== 最后 45 行 ==="
tail -n 45 "$L"
echo
echo "=== 关键事件 ==="
grep -nE 'exec (SpringBoard|backboardd|launchd)|SpringBoard|panic|PANIC|CRSH|blocked \(sweetnoexec\)|IOFindBSDRoot|hfs_mount|mount root|root file in userdata' "$L" | tail -40
echo
echo "=== 出现的 daemon exec 统计（前 25）==="
grep -oE '^exec [A-Za-z0-9._+-]+' "$L" | sort | uniq -c | sort -rn | head -25
