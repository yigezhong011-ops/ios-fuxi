#!/bin/bash
# Blob size and cave placement for the variants that booted (bl2, usbdiag2) and the ones that died at the green bar
# (USB_BOOTCPU), plus what follows the cave in the kernel: is the zero run after __hib_text really unused?
K=/root/fuxi/t36/kernel.macho
for defs in "-DBACKLIGHT" "-DBACKLIGHT -DUSB_DIAG" "-DBACKLIGHT -DUSB_DIAG -DUSB_BOOTCPU"; do
  printf '%-40s ' "$defs"
  BLOB_DEFS="$defs" REPLACE_SINK=1 python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-t32-buttons.py $K /tmp/k.$$ 2>&1 | grep -oE 'blob 0x[0-9a-f]+ bytes at 0x[0-9a-f]+|cave 0x[0-9a-f.]+ \(0x[0-9a-f]+ bytes\)' | tr '\n' ' '
  echo
done
rm -f /tmp/k.$$ /tmp/k.$$.blob.elf
echo "### sections/segments around the cave"
llvm-objdump --section-headers $K | grep -E '__hib|__TEXT_EXEC|__text |__KLD|__LAST|__PRELINK' | head -12
llvm-nm -n $K | awk '$1 >= "fffffff00c08d000" && $1 <= "fffffff00c092000"' | head -20
