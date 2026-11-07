#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/ios16-root-v11-fixed.simg
echo "=== 在原始 root 镜像里找 FuxiMetal 相关字符串 ==="
LC_ALL=C strings -a "$P" 2>/dev/null | grep -E 'FuxiMetal|fuxi-metal-smoke|FuxiMTLDevice' | sort -u | head -10
echo "(空 = 原始 root 里没有这些)"
echo
echo "=== 对比：我们做的 metal root ==="
LC_ALL=C strings -a /mnt/e/DSH-Fuxi/gles-root6-metal.simg 2>/dev/null | grep -E 'FuxiMetal|fuxi-metal-smoke|FuxiMTLDevice' | sort -u | head -10
