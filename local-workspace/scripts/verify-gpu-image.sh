#!/bin/bash
# Read the addon and trust cache back out of a built image and check them.
# Usage: verify-gpu-image.sh <image> <expected addon> <expected trustcache>
set -uo pipefail
IMG=$1
WANT_ADDON=${2:-}
WANT_TRUST=${3:-}
W=/root/fuxi/verify-img
rm -rf "$W"; mkdir -p "$W"

python3 - "$IMG" "$W" <<'PY'
import struct, sys, zlib
from pathlib import Path
img, w = Path(sys.argv[1]), Path(sys.argv[2])
d = img.read_bytes()
hs = struct.unpack_from('<I', d, 20)[0]
ks = struct.unpack_from('<I', d, 8)[0]
start = (hs + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ks])
fat = next(m for m in range(0, 8 << 20, 2)
           if len(body[m:m+512]) == 512 and body[m+0x52:m+0x5a].startswith(b'FAT32')
           and body[m+0x1fe:m+0x200] == b'\x55\xaa')
total = struct.unpack_from('<I', body, fat + 32)[0]
(w / 'vol.img').write_bytes(body[fat:fat + total * 512])
print('镜像 %d 字节，卷 %d 字节' % (len(d), total * 512))
PY

export MTOOLS_SKIP_CHECK=1
mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > "$W/addon.bin"
mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.trustcache > "$W/trust.bin"
mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho > "$W/kernel.macho"

echo "附加包 $(stat -c%s "$W/addon.bin") 字节"
echo "信任缓存 $(stat -c%s "$W/trust.bin") 字节"
echo "内核 $(stat -c%s "$W/kernel.macho") 字节"

python3 - "$W/addon.bin" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
cnt = struct.unpack_from('<I', d, 8)[0]
off = 24
names = []
for _ in range(cnt):
    nl, md, sz, cs = struct.unpack_from('<IIQQ', d, off)
    off += 24
    nm = d[off:off + nl - 1].decode()
    off += nl + (-nl % 8) + cs + (-cs % 8)
    names.append(nm)
print('  %d 个条目' % cnt)
for n in names:
    print('   ', n)
PY

python3 - "$W/trust.bin" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
count = struct.unpack_from('<I', d)[0]
starts = list(struct.unpack_from('<%dI' % count, d, 4))
start, end = starts[0], (starts[1] if count > 1 else len(d))
entries = struct.unpack_from('<I', d, start + 20)[0]
print('  信任模块 %d 个，owner 模块 %d 条哈希:' % (count, entries))
for i in range(entries):
    at = start + 24 + i * 24
    print('   ', d[at:at + 20].hex())
PY

if [ -n "$WANT_ADDON" ] && [ -f "$WANT_ADDON" ]; then
  cmp -s "$W/addon.bin" "$WANT_ADDON" && echo "✓ 附加包与预期文件逐字节一致" || echo "✗ 附加包不一致"
fi
if [ -n "$WANT_TRUST" ] && [ -f "$WANT_TRUST" ]; then
  cmp -s "$W/trust.bin" "$WANT_TRUST" && echo "✓ 信任缓存与预期文件逐字节一致" || echo "✗ 信任缓存不一致"
fi
