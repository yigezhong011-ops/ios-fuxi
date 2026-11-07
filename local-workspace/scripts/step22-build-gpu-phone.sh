#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-gpu-phone.log) 2>&1
cd /root/ios-fuxi/shim/fuxi-loader

echo "=== 用手机自带固件重新编译 shim ==="
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw-phone/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw-phone/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/mnt/e/DSH-Fuxi/dump/fw-phone/a740_zap.mbn
ls -l "$FUXI_GMU_FIRMWARE" "$FUXI_SQE_FIRMWARE" "$FUXI_GPU_ZAP_MBN"
bash build.sh /root/fuxi/payload.bin 2>&1 | tail -8

cp ../out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/fuxi-gpu-phone.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-gpu-phone.img
echo GPU_PHONE_BUILD_OK
