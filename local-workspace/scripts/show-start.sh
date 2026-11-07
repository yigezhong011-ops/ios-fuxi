#!/bin/bash
set -uo pipefail
S=/root/fuxi/authbuild/start.S
echo "=== start.S 里的跳转 ==="
grep -n 'loader_main\|bl\b\|b ' "$S" | head -12
echo
echo "=== 末尾 20 行 ==="
tail -20 "$S"
