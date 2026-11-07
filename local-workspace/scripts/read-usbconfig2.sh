#!/bin/bash
# Read-only: callers of ConfigUsb's inner function and the code that turns the protocol's mode value into its argument.
D=/root/fuxi/usbconfig.dis
for n in $(grep -n 'bl.*0x1f70' "$D" | cut -d: -f1 | head -3); do
  echo "-- caller at line $n"; sed -n "$((n - 14)),$((n + 1))p" "$D" | sed -E 's/<.*>//' | cut -c5-56
done
grep -n -E '#0x(10000|20|10|8)\b' "$D" | grep -E 'cmp|subs|tbnz|tbz|tst' | cut -c1-60 | head -24
strings -a -n 5 /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Binaries/nuwa/QcomPkg/Drivers/UsbConfigDxe/UsbConfigDxe.efi | grep -E 'USB_[A-Z_]+|Invalid ModeType|StartController|UsbConfig[A-Z]' | cut -c1-70 | sort -u | head -16
