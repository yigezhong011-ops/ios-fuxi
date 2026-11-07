#!/bin/bash
# GPU16 kernel with the expert's argument set: tells us whether the GPU16 kernel
# itself reaches userland when fed the args we know work.
set -euo pipefail
SRC=/mnt/e/DSH-Fuxi/boot-fuxi-GPU16.img
OUT=/mnt/e/DSH-Fuxi/g16-expertargs.img
W=/root/fuxi/g16x
M=$W/mnt
mkdir -p "$W" "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done

EXPERT_ARGS='-v serial=3 debug=0x14e boot-progress=2 kt_fixed_zones=120 offline-apfs-load=1 -apfs_shared_datavolume offline-key-events=1 offline-legacy-register=1 offline-legacy-gop=1 offline-legacy-unit-scale=2 offline-legacy-pm=1 offline-legacy-validate=1 offline-legacy-transfer=1 offline-legacy-cpu-present=1 offline-legacy-phase=4 offline-mobile-graphics-client=1 offline-mobile-graphics-load=1 boot-ui-focus4=SpringBoard native-fuxi-ufs-root=1 sheng-log=1 sheng-pmgr=2 armcpu-diagnostics=1 armcpu-spi-ipi=1 sheng-smp=1 sheng-cpufreq=4 sheng-aks=1 sheng-disable-watchdogd=1 sheng-lite=1 sheng-data-persist=2 qcom-usb-debug=1 -no_slto_panic ml-timeout-lock-panic-scale=40'

python3 - "$SRC" "$W/body.bin" "$W/tree.dtb" "$W/payload.img" <<'PY'
import struct, sys, zlib
src, body_out, tree_out, payload_out = sys.argv[1:5]
d = open(src, 'rb').read()
hsize = struct.unpack_from('<I', d, 20)[0]
ksize = struct.unpack_from('<I', d, 8)[0]
start = (hsize + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ksize])
open(body_out, 'wb').write(body)
open(tree_out, 'wb').write(un.unused_data)
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
total = struct.unpack_from('<I', body, fat + 32)[0]
open(payload_out, 'wb').write(body[fat:fat + total * 512])
PY

mount -t vfat -o loop,rw "$W/payload.img" "$M"
python3 - "$M/EFI/UniXNU/unixnu.toml" "$EXPERT_ARGS" <<'PY'
import re, sys
p, args = sys.argv[1], sys.argv[2]
t = open(p, encoding='utf-8', errors='replace').read()
t, n = re.subn(r'args = "[^"]*"', 'args = "%s"' % args, t)
open(p, 'w', encoding='utf-8').write(t)
print('  替换 %d 处' % n)
PY
sync
umount "$M"

python3 - "$W/payload.img" "$W/body.bin" "$W/tree.dtb" "$W/Image.gz-dtb" <<'PY'
import gzip, struct, sys
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
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 4 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -1
ls -lh "$OUT"
echo G16_EXPERTARGS_OK
