#!/bin/bash
set -uo pipefail
echo "=== FG_SCRATCH / FG_RAM_SIZE 定义 ==="
grep -rn 'define FG_SCRATCH\|define FG_RAM_SIZE\|FG_SCRATCH ' /root/ios-fuxi/shim/fuxi-loader/ /root/ios-fuxi/shim/fuxi-probe/ 2>/dev/null | head -10
echo
echo "=== 是否从 ADT 读 gpu 保留区 ==="
grep -rn 'fuxi-gpu-memory\|gpu_reserve\|gpu-memory' /root/ios-fuxi/shim/fuxi-loader/ /root/ios-fuxi/shim/fuxi-probe/ 2>/dev/null | head -10
