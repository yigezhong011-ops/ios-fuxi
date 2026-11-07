#!/bin/bash
# Rebuild the payload volume from scratch instead of editing the existing one:
# replacing a 126 MB file with a 52 MB one corrupted the FAT bookkeeping.
set -euo pipefail
W=/root/fuxi/pkg5
rm -rf "$W"; mkdir -p "$W/root/EFI/UniXNU/Payloads"
cd "$W"

echo "=== 准备文件 ==="
cp /root/fuxi/pkg4/kernel.macho              "$W/root/EFI/UniXNU/Payloads/kernel.macho"
cp /root/fuxi/pkg4/kernel.macho.adt          "$W/root/EFI/UniXNU/Payloads/kernel.macho.adt"
cp /root/fuxi/pkg4/kernel.macho.trustcache   "$W/root/EFI/UniXNU/Payloads/kernel.macho.trustcache"
cp /root/fuxi/pkg4/scratch-data.img          "$W/root/EFI/UniXNU/Payloads/scratch-data.img"
# the GPU addon comes from the expert payload
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mkdir -p "$W/mnt"
mount -t vfat -o loop,ro /root/fuxi/expert-payload-vol.img "$W/mnt"
cp "$W/mnt/EFI/UniXNU/Payloads/kernel.macho.gpuaddon" "$W/root/EFI/UniXNU/Payloads/kernel.macho.gpuaddon"
cp "$W/mnt/EFI/UniXNU/unixnu.toml" "$W/root/EFI/UniXNU/unixnu.toml"
umount "$W/mnt"
find "$W/root" -type f -printf '  %-58p %10s B\n' | sort

echo "=== 新卷（200 MiB，mformat）==="
IMG="$W/payload.img"
rm -f "$IMG"
truncate -s 200M "$IMG"
mformat -i "$IMG" -F -v FUXIESP ::
mcopy -i "$IMG" -s "$W/root/EFI" ::/
echo "--- 校验 ---"
mdir -i "$IMG" ::/EFI/UniXNU/Payloads
mtype -i "$IMG" ::/EFI/UniXNU/unixnu.toml | head -3

echo "=== 组装 boot.img ==="
python3 - <<'PY'
import gzip, struct, zlib
from pathlib import Path
w = Path('/root/fuxi/pkg5')
d = Path('/mnt/e/DSH-Fuxi/unixnu-expert-boot.img').read_bytes()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
tree = un.unused_data
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
print('  原 payload 区起点 %d' % fat)
payload = (w / 'payload.img').read_bytes()
(w / 'Image.gz-dtb').write_bytes(gzip.compress(body[:fat] + payload, mtime=0) + tree)
print('  gzip 主体 %d 字节' % (w / 'Image.gz-dtb').stat().st_size)
PY

printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o /mnt/e/DSH-Fuxi/unixnu-hybrid2.img 2>&1 | tail -1
ls -lh /mnt/e/DSH-Fuxi/unixnu-hybrid2.img
echo HYBRID2_OK
