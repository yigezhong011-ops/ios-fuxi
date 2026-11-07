#!/bin/bash
set -uo pipefail
cd /root/hackios
FD=/root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd

echo "=== A: hello payload @ 0xA7400000 ==="
python3 xnuloader/mkpayload.py -o out/hello-payload.bin loader.efi=out/hello.efi --usb
FD_BASE=0xA7100000 FD_SIZE=0x300000 PAYLOAD_BASE=0xA7400000 UEFI_TARGET=fuxi UEFI_FD=$FD \
python3 mkxnuimg.py -p out/hello-payload.bin -o out/fuxi-hello-a.img 2>&1 | tail -2
cp out/fuxi-hello-a.img /mnt/e/DSH-Fuxi/fuxi-hello-a.img

echo "=== B: 不带 payload ==="
FD_BASE=0xA7100000 FD_SIZE=0x300000 PAYLOAD_BASE=0xA7400000 UEFI_TARGET=fuxi UEFI_FD=$FD \
python3 mkxnuimg.py -o out/fuxi-nopayload.img 2>&1 | tail -2
cp out/fuxi-nopayload.img /mnt/e/DSH-Fuxi/fuxi-nopayload.img

echo "=== 两个镜像的 shim 是否都含 0xa740 ==="
for f in out/fuxi-hello-a.img out/fuxi-nopayload.img; do
python3 - "$f" <<'PY'
import zlib, struct, sys, pathlib
d = pathlib.Path(sys.argv[1]).read_bytes()
i = d.find(b'\x1f\x8b\x08')
raw = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[i:])
code = raw[64:240]
words = struct.unpack('<%dI' % (len(code)//4), code)
found = [hex((w >> 5) & 0xFFFF) for w in words if (w & 0xFFE0001F) == 0xD2A00005]
print(sys.argv[1], 'shim movz x5:', found, 'XNUP:', b'XNUP' in raw)
PY
done
ls -lh /mnt/e/DSH-Fuxi/fuxi-hello-a.img /mnt/e/DSH-Fuxi/fuxi-nopayload.img
