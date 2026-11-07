#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-pkgmon.log) 2>&1
cd /root/ios-fuxi/shim/fuxi-loader
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
# 用作者 boot 镜像里挖出来的正确固件
export FUXI_GMU_FIRMWARE=/root/fuxi/fw-correct/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/root/fuxi/fw-correct/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/root/fuxi/fw-correct/a740_zap.mbn
echo "GMU/SQE/ZAP:"
ls -l "$FUXI_GMU_FIRMWARE" "$FUXI_SQE_FIRMWARE" "$FUXI_GPU_ZAP_MBN"
echo "=== 用作者的 payload（cpus=6）+ 我们的 loader（含监控+触摸供电）==="
bash build.sh /root/fuxi/payload-pkg.bin 2>&1 | tail -4
cp ../out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/fuxi-pkgmon.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-pkgmon.img
echo PKGMON_OK
