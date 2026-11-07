#!/bin/bash
# Use ljhhkx529's exact kernel_args (from board.toml) in our payload, then repack.
set -euo pipefail
IMG=/mnt/e/DSH-Fuxi/unixnu-fuxi/fuxi/payload/payload.img
M=/root/fuxi/mnt/payload4
WORK=/root/fuxi/unixnu
OUT=${1:-/mnt/e/DSH-Fuxi/unixnu-fuxi-boot-ljj2.img}

read -r -d '' NEWARGS <<'EOF' || true
-v serial=3 debug=0x14e boot-progress=2 kt_fixed_zones=120 offline-apfs-load=1 -apfs_shared_datavolume offline-key-events=1 offline-legacy-register=1 offline-legacy-gop=1 offline-legacy-unit-scale=2 offline-legacy-pm=1 offline-legacy-validate=1 offline-legacy-transfer=1 offline-legacy-cpu-present=1 offline-legacy-phase=4 offline-mobile-graphics-client=1 offline-mobile-graphics-load=1 boot-ui-focus4=SpringBoard native-fuxi-ufs-root=1 sheng-log=1 sheng-pmgr=2 sheng-gpu-metal=1 sheng-gpu-addon=1 sheng-gpu-dcvs=1 sheng-fb-gpu=1 sheng-vsync=120 armcpu-diagnostics=1 armcpu-spi-ipi=1 sheng-smp=1 sheng-cpufreq=4 sheng-aks=1 sheng-gpu-power=9 sheng-disable-watchdogd=1 sheng-disable-jobs=com.apple.identityservicesd,com.apple.locationd,com.apple.CommCenter,com.apple.bluetoothd sheng-lite=1 sheng-data-persist=2 qcom-usb-debug=1 -no_slto_panic ml-timeout-lock-panic-scale=40
EOF
NEWARGS=$(echo "$NEWARGS" | tr '\n' ' ' | sed 's/  */ /g')

mkdir -p "$M"
for m in $(mount | awk '/vfat|msdos/{print $3}'); do umount -l "$m" 2>/dev/null || true; done
mount -t vfat -o loop,rw "$IMG" "$M"
python3 - "$M/EFI/UniXNU/unixnu.toml" "$NEWARGS" <<'PY'
import re, sys
path, newargs = sys.argv[1], sys.argv[2]
t = open(path).read()
t2, n = re.subn(r'args = "[^"]*"', 'args = "%s"' % newargs, t)
open(path, 'w').write(t2)
print('替换 %d 处，新长度 %d 字节' % (n, len(newargs)))
PY
sync
umount "$M"

echo "=== 重打包 ==="
cd "$WORK"
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 0 --pagesize 4096 \
  --kernel uefi.img --ramdisk "$IMG" --os_version 16.0.0 --os_patch_level 2026-08 -o "$OUT" 2>&1 | tail -2
ls -lh "$OUT"
echo LJJ2_OK
