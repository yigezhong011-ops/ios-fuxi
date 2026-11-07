#!/bin/bash
set -uo pipefail
D=/root/fuxi/fuxi.dts
echo "=== kgsl / 3d00000 / gmu 相关行 ==="
grep -n 'kgsl\|3d00000\|gmu\|gpucc' "$D" | head -25
echo
echo "=== gpu 节点块（搜 'kgsl-3d0' 附近 30 行）==="
line=$(grep -n 'kgsl-3d0' "$D" | head -1 | cut -d: -f1)
if [ -n "$line" ]; then sed -n "$((line-2)),$((line+30))p" "$D"; fi
echo
echo "=== SMMU 节点名 ==="
grep -n 'iommu@\|apps_smmu\|smmu' "$D" | head -12
