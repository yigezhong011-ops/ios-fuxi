#!/bin/bash
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old
sed -i 's/CONFIG_XNU_OWNER_ROOT_TRUST=y/CONFIG_XNU_OWNER_ROOT_TRUST=n/' configs/fuxi_gpu_defconfig
grep -n 'OWNER_ROOT' configs/fuxi_gpu_defconfig
git add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "configs: skip owner-root trust as well"
git push -q origin old
echo "已推送"
