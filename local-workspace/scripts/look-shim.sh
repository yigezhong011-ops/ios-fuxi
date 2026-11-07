#!/bin/bash
set -uo pipefail
cd /root/uefi-fuxi
echo "=== BootShim 目录 ==="
ls BootShim/ 2>/dev/null
echo
echo "=== BootShim 里和 x0/x1/寄存器传递相关 ==="
grep -rn -E 'x0|x1|_start|EntryArg|dtb|fdt|ramdisk|ANDROID' BootShim/*.S BootShim/*.c 2>/dev/null | head -30
