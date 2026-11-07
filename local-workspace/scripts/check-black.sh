#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon10/boot.log
echo "=== 行数 ==="; wc -l "$L"
echo "=== 最后 25 行（去 NUL）==="
tail -c 4000 "$L" | tr -d '\000' | tail -25
echo
echo "=== display off / backlight / present 相关 ==="
grep -a -nE 'display off|display on|backlight|presentWanted|off fades|SWEET FB: stats' "$L" | tail -10 || true
