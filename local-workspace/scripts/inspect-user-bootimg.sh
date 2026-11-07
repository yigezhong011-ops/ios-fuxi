#!/bin/bash
# Inspect the boot image the user is running (lock screen, no touch).
set -uo pipefail
IMG='/mnt/c/Users/USER/Downloads/boot.img 2'
ls -l "$IMG" 2>/dev/null || { echo "找不到文件"; exit 1; }
W=/root/insp-user
rm -rf "$W"; mkdir -p "$W/mnt"
python3 - "$IMG" "$W" <<'PY'
import struct, sys, zlib
from pathlib import Path
img, w = Path(sys.argv[1]), Path(sys.argv[2])
d = img.read_bytes()
print('文件 %d 字节' % len(d))
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
print('头 %d，内核区 %d' % (hsize, ksize))
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
tree = un.unused_data
print('主体 %d，设备树 %d' % (len(body), len(tree)))
(w / 'body.bin').write_bytes(body)
(w / 'tree.dtb').write_bytes(tree)
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
(w / 'payload.img').write_bytes(body[fat:fat + total * 512])
print('payload 起点 %d，大小 %d' % (fat, total * 512))
PY
echo "=== payload 内容 ==="
mdir -i "$W/payload.img" -/ ::/EFI/UniXNU/Payloads 2>/dev/null | tail -9
echo "=== 参数 ==="
mtype -i "$W/payload.img" ::/EFI/UniXNU/unixnu.toml 2>/dev/null | grep -o 'args = "[^"]*"' | sed 's/^args = "//; s/"$//' | tr ' ' '\n' | sort > "$W/args.txt"
cat "$W/args.txt" | tr '\n' ' ' | fold -w 150
echo
echo "=== 与 unixnu-touch 的差异 ==="
diff "$W/args.txt" /root/args-unixnu-touch.txt && echo "（完全相同）"
