#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device
echo "=== board.toml 里的组件/子模块选择 ==="
grep -n 'NativeMetal\|components\|submodules\|feeds' "$D/board.toml" | head -10 | cut -c1-160
echo
echo "=== .gitmodules 里有 NativeMetal 吗 ==="
grep -n 'NativeMetal' "$D/.gitmodules" | head -5
echo
echo "=== 树里有没有 drivers/NativeMetal ==="
ls -d /root/ux3/fuxi/tree/drivers/NativeMetal 2>/dev/null || echo "  没有"
echo
echo "=== 加速器脚本期待的文件 ==="
grep -n 'NativeMetal' "$D/scripts/build-adreno740-accelerator.py" 2>/dev/null | head -5 | cut -c1-170
