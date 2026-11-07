#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== build-arm-driver.py 里 verified-bundle 的目录选择 ==="
grep -n "verified" "$T/scripts/build-arm-driver.py" 2>/dev/null | head -14 | cut -c1-175
