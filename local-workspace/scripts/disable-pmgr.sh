#!/bin/bash
# The board builds without the PMGR archive (it needs a prelink candidate that only
# exists after the first link), so the kernel must not require it either.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

grep -n 'PMGR' configs/fuxi_gpu_defconfig || echo "  （defconfig 里没有 PMGR 行）"

sed -i 's/CONFIG_XNU_SHENG_PMGR=y/CONFIG_XNU_SHENG_PMGR=n/' configs/fuxi_gpu_defconfig
grep -n 'PMGR' configs/fuxi_gpu_defconfig || echo "  已无 PMGR 行（或不是 y）"

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "configs: build without the Sheng PMGR archive"
git push -q origin old
echo "已推送"
