#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-diag.log) 2>&1

KERNEL=/mnt/e/DSH-Fuxi/ci/kernel-diag/kernel.development.fuxi
ADT=/root/fuxi/fuxi.adt
CMDLINE=$(grep '^CMDLINE=' /mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh | sed 's/^CMDLINE="//; s/"$//')

echo "kernel: $KERNEL"
echo "cmdline: $CMDLINE"
ls -l "$KERNEL" "$ADT"

cd /root/ios-fuxi
cp "$KERNEL" /root/fuxi/kernel-diag.fuxi

echo "=== payload ==="
python3 tools/mkpayload.py /root/fuxi/kernel-diag.fuxi "$ADT" /root/fuxi/payload-diag.bin --cmdline "$CMDLINE" 2>&1 | tail -3

echo "=== shim + boot.img ==="
cd shim/fuxi-loader
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw-phone/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw-phone/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/mnt/e/DSH-Fuxi/dump/fw-phone/a740_zap.mbn
bash build.sh /root/fuxi/payload-diag.bin 2>&1 | tail -4

cp ../out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/fuxi-diag.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-diag.img
echo DIAG_BOOT_OK
