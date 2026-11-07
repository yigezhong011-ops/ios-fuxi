#!/bin/bash
# Boot image with OUR loader (which carries the USB monitor) around the CS-fix kernel.
set -euo pipefail
B=/root/fuxi/monbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.csfix.fuxi
OUT=/mnt/e/DSH-Fuxi/fuxi-monitor-csfix.img

mkdir -p "$B"
echo "=== 1) payload（新内核 + 作者 ADT + 控制台开）==="
CMDLINE=$(python3 - "$SRC/payload.bin" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6').replace(' sweetfb_noconsole=1', '')
cmd = ' '.join(a for a in cmd.split() if not a.startswith(('fuxibbgpu=', 'boot-uuid=', 'fuxiamfi=', 'vblur=', 'glcopy=', 'glcensus=')))
print(cmd)
PY
)
echo "$CMDLINE" | tr ' ' '\n' | grep -E 'cpus=|noconsole' | sed 's/^/  /'
python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$SRC/fuxi-root.adt" "$B/payload.bin" --cmdline "$CMDLINE" 2>&1 | tail -2

echo "=== 2) 用我们的 loader 打包（带 USB 监控）==="
cd /root/ios-fuxi/shim/fuxi-loader
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/root/fuxi/fw-correct/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/root/fuxi/fw-correct/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/root/fuxi/fw-correct/a740_zap.mbn
for f in "$MKBOOTIMG" "$FUXI_GMU_FIRMWARE" "$FUXI_SQE_FIRMWARE" "$FUXI_GPU_ZAP_MBN"; do
  [ -f "$f" ] || { echo "缺少 $f"; exit 1; }
done
bash build.sh "$B/payload.bin" 2>&1 | tail -6
cp ../out/fuxi-loader/fuxi-xnu-boot.img "$OUT"
ls -lh "$OUT"
echo MONITOR_OK
