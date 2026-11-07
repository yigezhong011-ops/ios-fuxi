#!/bin/bash
set -uo pipefail
D=/root/fuxi/fuxi2
echo "=== fuxi_softrender_defconfig 里与 root 相关 ==="
grep -n -i 'root\|crypto\|virtio' "$D/configs/fuxi_softrender_defconfig" | head -14 | cut -c1-140
echo
echo "=== 补丁系列里与 root 相关 ==="
grep -n -i 'root' "$D/patches/xnu/series" | head -10 | cut -c1-140
echo
echo "=== series 里前 20 个补丁 ==="
head -20 "$D/patches/xnu/series" | cut -c1-130
