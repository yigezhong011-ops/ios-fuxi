#!/bin/bash
set -uo pipefail
F=/root/ios-fuxi/shim/fuxi-loader/loader.c
echo "=== loader_main (200-228) ==="
sed -n '200,228p' "$F"
echo
echo "=== loader_boot (102-140) ==="
sed -n '102,140p' "$F"
