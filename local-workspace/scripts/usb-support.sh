#!/bin/bash
# Is the kernel USB debug console in the t32/t36 kernels, and is its switch in the daily args?
for s in qcom-usb-debug QcomXnuUsbDebug FuxiUsbCompat acquire_vbus; do
  printf '%-18s t32=%s t36=%s\n' "$s" "$(grep -c -a "$s" /root/fuxi/t32/kernel.macho)" "$(grep -c -a "$s" /root/fuxi/t36/kernel.macho)"
done
export MTOOLS_SKIP_CHECK=1
echo "t36-bl2 args with usb/serial/debug:"
mtype -i /root/fuxi/t36-bl2/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | tr ' ' '\n' | grep -iE 'usb|serial|debug'
echo "t32 args with usb:"; mtype -i /root/fuxi/t32/vol.img ::/EFI/UniXNU/unixnu.toml | grep -o 'args = "[^"]*"' | tr ' ' '\n' | grep -iE 'usb'
