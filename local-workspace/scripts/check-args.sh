#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon9/boot.log
echo "=== boot-args 行 ==="
grep -a 'boot-args' "$L" | head -2 | cut -c1-600 | tr -d '\000'
echo
echo "=== fuxidbgflush 是否在 cmdline 中 ==="
grep -a -c 'fuxidbgflush' "$L" || true
