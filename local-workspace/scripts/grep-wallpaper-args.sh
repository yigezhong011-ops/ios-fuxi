#!/bin/bash
set -uo pipefail
K=/root/rebuild/kernel-daily.macho
echo "=== 含 wallpaper 的启动参数名 ==="
strings -a "$K" 2>/dev/null | grep -E '^[a-z][a-z0-9-]*wallpaper[a-z0-9-]*$|wallpaper=[^ ]*$' | sort -u | head -10
echo
echo "=== 所有 sheng-* 参数里可能相关的 ==="
strings -a "$K" 2>/dev/null | grep -E '^sheng-[a-z0-9-]+$' | sort -u | head -40
