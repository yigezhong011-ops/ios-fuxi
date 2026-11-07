#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon13/boot.log
echo "=== SpringBoard 启动次数 ==="
grep -a -c 'exec SpringBoard' "$L" || true
echo "=== SpringBoard 崩溃 ==="
grep -a -c 'CRASH SpringBoard' "$L" || true
echo "=== backboardd 启动次数 ==="
grep -a -c 'exec backboardd' "$L" || true
echo "=== 所有 exec 的进程（去重）==="
grep -a -o '^exec [A-Za-z0-9._-]*' "$L" | sort | uniq -c | sort -rn | head -20
