#!/bin/bash
set -uo pipefail
I=/mnt/e/DSH-Fuxi/dump/iphonex-16.7.11.ipsw
echo "=== DMG / DeviceTree 条目 ==="
unzip -l "$I" | grep -E '\.dmg|DeviceTree\.d22ap' | head -20
echo
echo "=== 完整性（最后 3 行）==="
unzip -t "$I" 2>&1 | tail -3
