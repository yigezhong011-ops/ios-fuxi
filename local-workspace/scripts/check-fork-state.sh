#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git fetch -q origin old && git reset -q --hard origin/old
echo "=== 当前 HEAD ==="
git log --oneline -3
echo
echo "=== board.toml 的 GPU/PMGR 归档 ==="
grep -n 'build-sheng-platform-power\|Adreno740\|adreno740\|prepare-fuxi-gmu' board.toml | head -10
echo
echo "=== configs ==="
ls configs/
echo
echo "=== fuxi_gpu_defconfig 尾部 ==="
tail -4 configs/fuxi_gpu_defconfig 2>/dev/null
