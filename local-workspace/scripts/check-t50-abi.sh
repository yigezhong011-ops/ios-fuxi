#!/bin/bash
set -uo pipefail
echo "=== t50 相关镜像 ==="
ls -l /mnt/e/DSH-Fuxi/t50*.img 2>/dev/null
echo
echo "=== t50 卷 ==="
ls -l /root/fuxi/t50-mine/vol.img /root/fuxi/t50-mine/kernel.macho 2>/dev/null
echo
echo "=== 793d6bddf7 的插件源码是否容忍缺 TurnipReplay.h ==="
K=/root/fuxi/t50-mine/kernel.macho
echo "内核里 Adreno740 版本串:"
strings -a "$K" 2>/dev/null | grep -iE 'NativeAdreno.*(version|revision)|Adreno740' | sort -u | head -8 | cut -c1-120
echo
echo "内核里的 AdrenoMetal ABI 标记:"
strings -a "$K" 2>/dev/null | grep -iE 'NativeAdrenoABI|NativeAdrenoAbiMax|ABI version' | sort -u | head -8 | cut -c1-120
