#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/build-diag2.log) 2>&1
cd /root/ios-fuxi

KERNEL=/mnt/e/DSH-Fuxi/ci/kernel-diag/kernel.development.fuxi
EXT=/mnt/e/DSH-Fuxi/dump/ext-bytes.json
FDT=/mnt/e/DSH-Fuxi/dump/fuxi-dump/fdt
CMDLINE=$(grep '^CMDLINE=' /mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh | sed 's/^CMDLINE="//; s/"$//')

ROOT_BYTES=$(python3 -c "import json;print(json.load(open('$EXT'))['size'])")
echo "root bytes=$ROOT_BYTES extents=$(python3 -c "import json;print(len(json.load(open('$EXT'))['extents']))")"

echo "=== ADT（从当前 ext-bytes.json 重新生成）==="
cp "$FDT" /tmp/live.fdt
python3 tools/mkadt-fuxi.py /root/fuxi/fuxi.adt --live-fdt /tmp/live.fdt \
  --root-extents "$EXT" --root-bytes "$ROOT_BYTES" --gpu-reserve --smp 2>&1 | tail -2
ls -l /root/fuxi/fuxi.adt

echo "=== payload ==="
cp "$KERNEL" /root/fuxi/kernel-diag.fuxi
python3 tools/mkpayload.py /root/fuxi/kernel-diag.fuxi /root/fuxi/fuxi.adt /root/fuxi/payload-diag.bin --cmdline "$CMDLINE" 2>&1 | tail -2

echo "=== shim ==="
cd shim/fuxi-loader
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw-phone/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/mnt/e/DSH-Fuxi/dump/fw-phone/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/mnt/e/DSH-Fuxi/dump/fw-phone/a740_zap.mbn
bash build.sh /root/fuxi/payload-diag.bin 2>&1 | tail -3
cp ../out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/fuxi-diag.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-diag.img
echo DIAG2_OK
