#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-v3.log) 2>&1
cd /root/ios-fuxi/shim/fuxi-loader

echo "=== 备份 bangprovn 的 loader，换成 hanzi 的（第一次 boot 能看到 XNU 输出的那套）==="
[ -f loader.c.bangprovn ] || cp loader.c loader.c.bangprovn
[ -f start.S.bangprovn ]  || cp start.S start.S.bangprovn
cp /mnt/e/DSH-Fuxi/dump/fw/hanzi-loader.c loader.c
cp /mnt/e/DSH-Fuxi/dump/fw/hanzi-start.S start.S
# 与作者 CI 相同的一处补丁：这台机器 ABL 直接落到 EL1
sed -i 's/^ b\.ne fatal/ nop \/* ABL drops to EL1 on this unit *\//' start.S
grep -n 'CurrentEL' -A2 start.S | head -6 || true

echo "=== 重新打包（payload 不变）==="
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/mnt/e/DSH-Fuxi/dump/fw/a740_zap.mbn
bash build.sh /root/fuxi/payload.bin 2>&1 | tail -6

ls -lh ../out/fuxi-loader/fuxi-xnu-boot.img
cp ../out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/dump/fuxi-xnu-boot-v3.img
echo "BUILD_V3_OK"
