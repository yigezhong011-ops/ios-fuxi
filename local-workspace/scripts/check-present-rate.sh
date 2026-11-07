#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon43/boot.log
echo "=== 扫出的帧数（FUXI SCANOUT frame=N）==="
tr -d '\000' < "$L" | grep -a -o 'FUXI SCANOUT: frame=[0-9]*' | tail -3
echo "行数: $(tr -d '\000' < "$L" | grep -a -c 'FUXI SCANOUT: frame=')"
echo
echo "=== swap 计数 ==="
tr -d '\000' < "$L" | grep -a -o 'SWEET FB: [0-9]* swaps' | tail -2
echo
echo "=== 延迟/丢弃提示 ==="
tr -d '\000' < "$L" | grep -a -i 'not shown\|defer\|drop' | tail -5
echo
echo "=== GPU pending / busy ==="
tr -d '\000' < "$L" | grep -a -i 'gpuBusy\|fGpuPending\|GPU: presents' | tail -5
