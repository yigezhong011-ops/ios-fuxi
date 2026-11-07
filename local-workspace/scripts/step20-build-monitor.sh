#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-monitor.log) 2>&1
cd /root/ios-fuxi/shim/fuxi-loader

echo "=== 换回 bangprovn 的 loader（带 USB 监控 + ufs.c）==="
cp loader.c.bangprovn loader.c
cp start.S.bangprovn start.S
sed -i 's/^ b\.ne fatal/ nop \/* ABL drops to EL1 on this unit *\//' start.S
grep -n 'CurrentEL' -A2 start.S | head -4 || true

echo "=== 编译 ==="
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/mnt/e/DSH-Fuxi/dump/fw/a740_zap.mbn
bash build.sh /root/fuxi/payload.bin 2>&1 | tail -6

cp ../out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/fuxi-monitor-boot.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-monitor-boot.img
echo MONITOR_BOOT_OK
