#!/bin/bash
set -uo pipefail
echo "=== start.S 行数 ==="
wc -l /root/ios-fuxi/shim/fuxi-loader/start.S
echo "=== 前 70 行 ==="
sed -n '1,70p' /root/ios-fuxi/shim/fuxi-loader/start.S
