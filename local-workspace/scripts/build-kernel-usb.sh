#!/bin/bash
set -uo pipefail
cd /root/wslkernel
echo "=== 改配置：USB 与 USB/IP 全部内置 ==="
./scripts/config --enable USB --enable USB_SUPPORT --enable USBIP_CORE --enable USBIP_VHCI_HCD --enable USBIP_HOST
make olddefconfig > /tmp/cfg3.log 2>&1
grep -E '^CONFIG_USBIP|^CONFIG_USB=' .config
echo "=== 编译 bzImage ==="
make -j32 bzImage > /tmp/kbz2.log 2>&1
echo "BUILD=$?"
tail -3 /tmp/kbz2.log
ls -lh /root/wslkernel/arch/x86/boot/bzImage
cp /root/wslkernel/arch/x86/boot/bzImage /mnt/e/WSL/bzImage
echo KERNEL_USB_DONE
