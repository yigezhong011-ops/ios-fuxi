#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== 树里 NativeMetal 的内容 ==="
ls "$T/drivers/NativeMetal" 2>/dev/null | head -12 || echo "  目录不存在"
echo
echo "=== 找 OriginalAcceleratorABI.h ==="
find "$T" -name 'OriginalAcceleratorABI.h' 2>/dev/null | head -3
echo
echo "=== Adreno740 的 accelerator 源文件第 1-15 行 ==="
sed -n '1,15p' "$T/drivers/Adreno740/NativeAdrenoAccelerator.cpp" 2>/dev/null
echo
echo "=== 加速器脚本第 40-65 行 ==="
sed -n '40,65p' "$T/scripts/build-adreno740-accelerator.py" 2>/dev/null | cut -c1-160
