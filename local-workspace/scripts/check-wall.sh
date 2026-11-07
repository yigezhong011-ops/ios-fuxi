#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon11/boot.log
echo "=== 行数 ==="; wc -l "$L"
echo "=== poster / wallpaper ==="
grep -a -niE 'poster|wallpaper|autobahn' "$L" | head -12 || echo "(none)"
echo "=== 崩溃统计 ==="
grep -a -c 'CRASH ' "$L" || true
grep -a -o 'CRASH [A-Za-z0-9._-]*' "$L" | sort | uniq -c | sort -rn | head -8
echo "=== 末尾 8 行 ==="
tail -c 1500 "$L" | tr -d '\000' | tail -8
