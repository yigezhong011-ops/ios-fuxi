#!/bin/bash
# The archive is now built without the verified-root bundle, so point the config at
# the plain output directory.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

sed -i 's|build/native-virtio-block-verified-bundle/libNativeVirtioBlock.a|build/native-virtio-block/libNativeVirtioBlock.a|' configs/fuxi_gpu_defconfig
grep -n 'VIRTIO_BLOCK_ARCHIVE' configs/fuxi_gpu_defconfig

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "configs: point the virtio block archive at the plain build directory"
git push -q origin old
echo "已推送"
