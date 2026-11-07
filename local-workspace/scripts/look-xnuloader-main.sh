#!/bin/bash
set -uo pipefail
F=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
echo "=== Log() 实现 ==="
awk '/^Log \(/,/^}/' "$F" | head -30
echo
echo "=== XnuLoaderMain ==="
awk '/^XnuLoaderMain/,/^}/' "$F" | head -40
echo
echo "=== 分区写入 / 重启 ==="
grep -n -E 'logdump|ResetSystem|XNU_LOG_PARTITION|LocateHandle|SimpleFileSystem' "$F" | head -15
