#!/bin/bash
set -uo pipefail
K=/root/rebuild/kernel-daily.macho
echo "=== 内核里的 wallpaper 相关字符串 ==="
strings -a "$K" 2>/dev/null | grep -i 'wallpaper' | sort -u | head -20 | cut -c1-140
echo
echo "=== ngpu 路径 ==="
strings -a "$K" 2>/dev/null | grep -E 'ngpu/[a-z-]+' | sort -u | head -12
echo
echo "=== 与挂载相关的（mount/overlay）==="
strings -a "$K" 2>/dev/null | grep -iE 'sheng.*(mount|overlay)|gpu-addon.*mount' | sort -u | head -10 | cut -c1-130
