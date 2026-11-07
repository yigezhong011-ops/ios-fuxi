#!/bin/bash
set -uo pipefail
echo "=== 设备仓库里产出 addon 的脚本 ==="
grep -rn 'addon' /root/fuxi/fork-device/board.toml 2>/dev/null | head -8 | cut -c1-150
echo
echo "=== scripts 列表里含 addon/gpu 的 ==="
ls /root/fuxi/fork-device/scripts | grep -i 'addon\|gpu\|pack' | head -10
echo
echo "=== 上游 tree 里打包 addon 的地方 ==="
grep -rln 'gpuaddon\|pack-addon\|addon' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/*.py 2>/dev/null | head -6
grep -rn 'def .*addon\|pack_addon\|--addon' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/unixnu/*.py 2>/dev/null | head -8 | cut -c1-150
