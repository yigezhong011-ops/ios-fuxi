#!/bin/bash
# Read-only: can the loader be rebuilt here, and how do the images get it?
cd /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi || exit 1
tail -n 6 Build/BUILDLOG_fuxiPkg.txt | cut -c1-140
ls -la Resources/ 2>/dev/null | head; ls scripts | head -20
ls -la /root/fuxi/*uefi* /root/fuxi/*loader* 2>/dev/null | head
which clang aarch64-linux-gnu-gcc iasl nasm gcc-aarch64-linux-gnu 2>/dev/null
grep -n -E 'loader|uefi|UEFI' /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py | head -10 | cut -c1-120
sed -n 1,60p .github/workflows/build-fuxi-uefi.yml | grep -n -E 'run:|build|apt|clang|gcc' | cut -c1-110 | head -16
python3 - <<'PY'
import struct, zlib
d = open('/mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img', 'rb').read(); ks = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(31).decompress(d[4096:4096 + ks])
print('head', b[:64].hex())
fat = next(m for m in range(0, 8 << 20, 2) if b[m+0x52:m+0x5a].startswith(b'FAT32') and b[m+0x1fe:m+0x200] == b'\x55\xaa')
print('loader bytes before volume', hex(fat))
open('/root/fuxi/loader.bin', 'wb').write(b[:fat])
PY
