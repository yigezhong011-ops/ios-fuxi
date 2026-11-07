#!/bin/bash
set -euo pipefail
cd /root/fuxi
echo "=== 修 native payload 的 cpus=7 -> 6 ==="
python3 - <<'PY'
import pathlib
p = pathlib.Path('/root/fuxi/payload-native.bin')
b = bytearray(p.read_bytes())
assert b[:8] == b'SWEETXNU'
base = 0x48
cmd = bytes(b[base:base+608]).split(b'\0')[0]
i = cmd.find(b'cpus=7')
print('原尾部:', cmd[-160:].decode(errors='replace'))
if i >= 0:
    b[base+i:base+i+6] = b'cpus=6'
    p.write_bytes(bytes(b))
    print('已改为 cpus=6')
else:
    print('没有 cpus=7（可能已不同）')
print('新尾部:', bytes(b[base:base+608]).split(b'\0')[0][-160:].decode(errors='replace'))
PY

echo "=== 用正确固件 + 我们的 loader 打包 native 版 ==="
cd /root/ios-fuxi/shim/fuxi-loader
export CLANG=clang LLD=ld.lld OBJCOPY=llvm-objcopy READELF=llvm-readelf
export MKBOOTIMG=/mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py
export FUXI_GMU_FIRMWARE=/root/fuxi/fw-correct/gmu_gen70200.bin
export FUXI_SQE_FIRMWARE=/root/fuxi/fw-correct/a740_sqe.fw
export FUXI_GPU_ZAP_MBN=/root/fuxi/fw-correct/a740_zap.mbn
bash build.sh /root/fuxi/payload-native.bin 2>&1 | tail -3
cp ../out/fuxi-loader/fuxi-xnu-boot.img /mnt/e/DSH-Fuxi/fuxi-pkgnative.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-pkgmon.img /mnt/e/DSH-Fuxi/fuxi-pkgnative.img
echo NATIVE_OK
