#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-boot.log) 2>&1
cd /root/ios-fuxi

EXT=/tmp/ext.json
KERNEL=/tmp/kernel.fuxi
[ -f "$KERNEL" ] || cp /mnt/e/DSH-Fuxi/dump/artifacts/fuxi-kernel/kernel.development.fuxi "$KERNEL"
ROOT_BYTES=$(python3 -c "import json;print(json.load(open('$EXT'))['size'])")
echo "root bytes: $ROOT_BYTES  extents: $(python3 -c "import json;print(len(json.load(open('$EXT'))['extents']))")"

echo "=== 1) ADT ==="
python3 tools/mkadt-fuxi.py /root/fuxi/fuxi.adt \
  --live-fdt /tmp/live.fdt \
  --root-extents "$EXT" --root-bytes "$ROOT_BYTES" \
  --gpu-reserve --smp

echo "=== 2) payload ==="
CMDLINE="debug=0x14e serial=3 cpus=7 keepsyms=1 -v rd=ufsroot0 ufsrw=1 rootrw=1 unentitled_ios_sim_launch=1 ignition_level=1 launchd_unsecure_cache=1 wdt=-1 sweetlog=1 fuxigpu=1 fuxiperf=1"
python3 tools/mkpayload.py "$KERNEL" /root/fuxi/fuxi.adt /root/fuxi/payload.bin --cmdline "$CMDLINE" | tail -12

echo "=== 3) shim + boot.img ==="
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/mnt/e/DSH-Fuxi/dump/fw/a740_zap.mbn
bash shim/fuxi-loader/build.sh /root/fuxi/payload.bin 2>&1 | tail -15

ls -lh shim/out/fuxi-loader/Image shim/out/fuxi-loader/fuxi-xnu-boot.img 2>&1
cp shim/out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/dump/fuxi-xnu-boot-16g.img
echo "BUILD_BOOT_OK"

