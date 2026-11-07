#!/bin/bash
set -uo pipefail
F=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
echo "=== payload 地址相关 ==="
grep -n -i 'payload\|PAYLOAD_BASE\|0x[0-9A-Fa-f]\{8\}' "$F" | head -25
echo
echo "=== XnuLoaderMain 开头 40 行 ==="
awk '/VOID[[:space:]]*$/{f=1} f' "$F" | head -5
sed -n '1,60p' "$F"
