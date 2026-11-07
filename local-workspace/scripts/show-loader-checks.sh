#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/shim/fuxi-loader/loader.c
echo "=== loader_boot 里的校验 ==="
sed -n '194,300p' "$F" | grep -n 'return "\|if (' | head -30
