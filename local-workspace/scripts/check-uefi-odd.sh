#!/bin/bash
set -uo pipefail
U=/root/uefi-odd
echo "=== 有没有已编好的固件 ==="
find "$U" -name 'SILICIUM_UEFI.fd' -o -name '*.fd' 2>/dev/null | head -8
echo
echo "=== Build 目录 ==="
ls "$U/Build" 2>/dev/null | head -5
echo
echo "=== fuxi 平台在不在 ==="
ls "$U/Platforms/Xiaomi" 2>/dev/null | head -5
echo
echo "=== 占用大头 ==="
du -sh "$U"/* 2>/dev/null | sort -h | tail -6
