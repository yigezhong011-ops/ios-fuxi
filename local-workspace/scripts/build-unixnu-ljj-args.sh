#!/bin/bash
# Replace the kernel args in the payload's unixnu.toml with ljhhkx529's
# known-good fuxi set (their README), then repack the boot image.
set -euo pipefail
IMG=/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img
M=/root/fuxi/mnt/payload2
WORK=/root/fuxi/unixnu
OUT=${1:-/mnt/e/DSH-Fuxi/unixnu-fuxi-boot-ljj.img}

mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,rw "$IMG" "$M"

echo "=== 原参数 ==="
grep -o 'args = "[^"]*"' "$M/EFI/UniXNU/unixnu.toml" | head -c 300; echo

NEWARGS='-v serial=3 debug=0x14e kt_fixed_zones=120 offline-legacy-register=1 offline-legacy-gop=1 offline-legacy-unit-scale=2 offline-legacy-pm=1 offline-legacy-validate=1 offline-legacy-transfer=1 offline-legacy-cpu-present=1 offline-hid-home=1 offline-hid-input=1 offline-legacy-phase=4 offline-mobile-graphics-client=1 offline-mobile-graphics-load=1 offline-apfs-load=1 boot-progress=2 sheng-pmgr=2 native-fuxi-ufs-root=1 native-ufs-diagnostics=1 qcom-usb-debug=1 -enable_kprintf_spam -apfs_shared_datavolume offline-key-events=1 armcpu-diagnostics=1 armcpu-spi-ipi=1 -no_slto_panic ml-timeout-lock-panic-scale=40 sheng-gpu-metal=1 sheng-fb-gpu=1 sheng-backlight=1 sheng-vsync=120 sheng-log=1 sheng-data-persist=2 sheng-disable-watchdogd=1 sheng-lite=1'

python3 - "$M/EFI/UniXNU/unixnu.toml" "$NEWARGS" <<'PY'
import re, sys
path, newargs = sys.argv[1], sys.argv[2]
t = open(path).read()
n = 0
def repl(m):
    global n
    n += 1
    return 'args = "%s"' % newargs
t2 = re.sub(r'args = "[^"]*"', repl, t)
open(path, 'w').write(t2)
print('替换了 %d 处 args' % n)
PY

echo "=== 新参数（片段）==="
grep -o 'args = "[^"]*"' "$M/EFI/UniXNU/unixnu.toml" | head -c 400; echo

sync
umount "$M"
echo "=== 重打包（v0 + 192MB payload）==="
cd "$WORK"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 0 --pagesize 4096 \
  --kernel uefi.img --ramdisk "$IMG" \
  --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -2
ls -lh "$OUT"
echo LJJ_BOOT_OK
