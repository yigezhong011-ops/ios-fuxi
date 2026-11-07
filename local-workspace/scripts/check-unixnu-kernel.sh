#!/bin/bash
set -uo pipefail
K=/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/kernel/kernel.macho
echo "=== 大小 ==="
ls -lh "$K"
echo
echo "=== 版本字符串 ==="
strings -a "$K" | grep -m6 -E 'Darwin Kernel Version|xnu-[0-9]+|RELEASE_ARM64' | head -8
echo
echo "=== iOS 版本相关（17.x / 16.x / 20H / 21A）==="
strings -a "$K" | grep -oE '2[01][A-Z][0-9]{2,4}' | sort -u | head -12
echo
echo "=== 支持的设备型号（iPad7,1 / iPhone10,3）==="
strings -a "$K" | grep -oE '(iPad|iPhone)[0-9]+,[0-9]+' | sort -u | head -10
