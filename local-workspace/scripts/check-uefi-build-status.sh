#!/bin/bash
set -uo pipefail
echo "=== UEFI 日志尾部 ==="
tail -8 /root/uefi-hakios.log 2>/dev/null
echo
echo "=== 是否在构建 ==="
pgrep -f 'build_uefi' >/dev/null && echo "构建进程在跑" || echo "构建进程已退出"
echo
echo "=== 产物 ==="
find /root/uefi-hak-fuxi -name 'SILICIUM_UEFI.fd' 2>/dev/null | head -3
ls -l /root/uefi-hak-fuxi/Build 2>/dev/null | head -6
