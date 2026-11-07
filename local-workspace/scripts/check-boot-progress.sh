#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
A=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/kernel.development.fuxi
echo "=== 我们的内核里的 boot progress 相关串 ==="
strings -a "$K" | grep -iE 'boot.?progress|progress.?bar|AppleBootProgress|boot-progress' | sort -u | head -10
echo "(空 = 没有实现)"
echo
echo "=== 作者的（闭源）内核里 ==="
strings -a "$A" | grep -iE 'boot.?progress|progress.?bar|AppleBootProgress|boot-progress' | sort -u | head -10
echo
echo "=== 两边 payload 大小对比（影响进度条每格宽度）==="
ls -l "$K" "$A" | awk '{print $5, $9}'
