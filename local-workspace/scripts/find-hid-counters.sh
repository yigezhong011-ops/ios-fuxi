#!/bin/bash
# HID probe counters in the original t32 kernel, and the inputs make-t32-buttons*.sh use
ls /root/fuxi/t32/
K=$(grep -o '/root/fuxi/t32/[^ ]*kernel[^ ]*\.macho' /mnt/e/DSH-Fuxi/dump/wsl/make-t32-buttons-diag.sh | head -1)
echo "script kernel: $K"
grep -n -E 'kernel|KERNEL|patch-t32' /mnt/e/DSH-Fuxi/dump/wsl/make-t32-buttons-diag.sh
for f in /root/fuxi/t32/kernel.macho /root/fuxi/t32/payload/kernel.macho; do
    [ -f "$f" ] && { echo "== $f"; llvm-nm --defined-only "$f" | grep -E 'native_hid_input_(events|results|object)|native_hid_(stage|resource_found)|native_fuxi_touch_enabled|native_touch_hid_reports'; }
done
