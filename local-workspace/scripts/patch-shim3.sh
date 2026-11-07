#!/bin/bash
set -euo pipefail
SHIM=/root/uefi-fuxi/BootShim/BootShim.S
cp "$SHIM.orig" "$SHIM"
python3 - "$SHIM" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()

# save x0 at the first instruction of _Start (after the ARM64 header block)
old = """_Start:
  mov   x4, x1"""
new = """_Start:
  mov   x19, x0         /* keep the bootloader's device tree pointer */
  mov   x4, x1"""
assert old in t, 'start anchor missing'
t = t.replace(old, new, 1)

# restore it right before jumping into the firmware volume
old2 = """  dsb   sy
  ic    iallu
  dsb   sy
  isb
  br    x5"""
new2 = """  dsb   sy
  ic    iallu
  dsb   sy
  isb
  mov   x0, x19         /* hand SEC the device tree in x0 */
  br    x5"""
assert old2 in t, 'entry anchor missing'
t = t.replace(old2, new2, 1)
p.write_text(t)
print('shim patched after the header block')
PY
grep -n -A2 '_Start:' "$SHIM" | head -6
cd /root/UniXNU
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
python3 ./unixnu bootimg -D /root/UniXNU-fuxi --uefi /root/uefi-fuxi \
  --fd /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd \
  --dtb "$OUT/device-tree/hardware.dtb" \
  --ramdisk "$OUT/payload/payload.img" \
  -o "$OUT/boot/boot.img" 2>&1 | grep -E 'DEBUG shim|unixnu:|error' | head -4
cp "$OUT/boot/boot.img" /mnt/e/DSH-Fuxi/unixnu-boot.img
ls -lh /mnt/e/DSH-Fuxi/unixnu-boot.img
