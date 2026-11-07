#!/bin/bash
# Combine the kernel that reaches userland (the expert payload) with GPU16's
# staged GPU bring-up arguments, which avoid the Metal/fb-gpu path that traps.
set -euo pipefail
SRC=/mnt/e/DSH-Fuxi/unixnu-expert-boot.img
NEWARGS='-v serial=3 debug=0x14e kt_fixed_zones=120 offline-legacy-register=1 offline-legacy-gop=1 offline-legacy-unit-scale=2 offline-legacy-pm=1 offline-legacy-validate=1 offline-legacy-transfer=1 offline-legacy-cpu-present=1 offline-hid-home=1 offline-hid-input=1 offline-legacy-phase=4 offline-mobile-graphics-client=1 offline-mobile-graphics-load=1 offline-apfs-load=1 boot-progress=2 sheng-pmgr=2 native-ufs-root=1 native-ufs-diagnostics=1 qcom-usb-debug=1 -enable_kprintf_spam -apfs_shared_datavolume offline-key-events=1 armcpu-diagnostics=1 -no_slto_panic ml-timeout-lock-panic-scale=40 fuxi-owner-skip-root-auth=1 sheng-gpu-addon=1 sheng-gpu-start=1 sheng-gpu-match=1 sheng-gpu-run=1 fuxi-enable-ignition=1 ignition_level=1 sheng-smp=1 armcpu-spi-ipi=1 panic_on_crash_disabled=1 sheng-disable-jobs=com.apple.watchdogd'
OUT=/mnt/e/DSH-Fuxi/unixnu-staged-gpu.img
W=/root/fuxi/staged
M=$W/mnt
mkdir -p "$W" "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

echo "=== 1) 取专家镜像主体与设备树 ==="
python3 - "$SRC" "$W/body.bin" "$W/tree.dtb" <<'PY'
import struct, sys, zlib
d = open(sys.argv[1], 'rb').read()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
open(sys.argv[2], 'wb').write(body)
open(sys.argv[3], 'wb').write(un.unused_data)
print('  主体 %d，设备树 %d' % (len(body), len(un.unused_data)))
PY

echo "=== 2) 切出 payload 卷 ==="
python3 - "$W/body.bin" "$W/payload.img" <<'PY'
import struct, sys
body = open(sys.argv[1], 'rb').read()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
open(sys.argv[2], 'wb').write(body[fat:fat + total * 512])
print('  卷 %d 字节 @ %d' % (total * 512, fat))
PY

echo "=== 3) 换 args ==="
mount -t vfat -o loop,rw "$W/payload.img" "$M"
python3 - "$M/EFI/UniXNU/unixnu.toml" "$NEWARGS" <<'PY'
import re, sys
p, args = sys.argv[1], sys.argv[2]
t = open(p, encoding='utf-8', errors='replace').read()
t2, n = re.subn(r'args = "[^"]*"', 'args = "%s"' % args, t)
open(p, 'w', encoding='utf-8').write(t2)
print('  替换 %d 处' % n)
PY
sync
umount "$M"

echo "=== 4) 重新打包 ==="
python3 - "$W/payload.img" "$W/body.bin" "$W/tree.dtb" "$W/Image.gz-dtb" <<'PY'
import gzip, sys
payload, body_path, tree, out = sys.argv[1:5]
body = open(body_path, 'rb').read()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
blob = gzip.compress(body[:fat] + open(payload, 'rb').read(), mtime=0) + open(tree, 'rb').read()
open(out, 'wb').write(blob)
PY
printf '\0' > "$W/ramdisk1"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -1
ls -lh "$OUT"
echo STAGED_OK
