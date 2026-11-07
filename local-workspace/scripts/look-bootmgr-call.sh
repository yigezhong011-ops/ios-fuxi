#!/bin/bash
set -uo pipefail
F=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/BootManager.c
echo "=== XnuLoaderMain 调用点 ==="
grep -n -B15 -A5 'XnuLoaderMain' "$F" | head -40
echo
echo "=== 平台钩子函数 ==="
grep -n '^PlatformBootManager\|^VOID' "$F" | head -10
