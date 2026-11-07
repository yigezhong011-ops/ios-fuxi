#!/bin/bash
set -uo pipefail
echo "=== loader.c 1-55 ==="
sed -n '1,55p' /root/ios-fuxi/shim/fuxi-loader/loader.c
echo
echo "=== build.sh ==="
cat /root/ios-fuxi/shim/fuxi-loader/build.sh
