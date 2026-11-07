#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
EFI=$U/Silicon/Qualcomm/NicobarPkg/Drivers/UsbPwrEnablerDxe/UsbPwrEnablerDxe.efi
OBJ=$(ls /root/build/unixnu/out/fuxi/toolchain/llvm-objdump 2>/dev/null || which llvm-objdump)
echo "objdump: $OBJ"
echo
echo "=== 反汇编里的立即数（movz/movk）==="
"$OBJ" -d "$EFI" 2>/dev/null | grep -oE '#0x[0-9a-f]{4,}' | sort | uniq -c | sort -rn | head -20
echo
echo "=== 代码里像 MMIO 基址的常量 ==="
"$OBJ" -d "$EFI" 2>/dev/null | grep -E 'movz|movk' | grep -oE '#0x[0-9a-f]{5,}' | sort -u | head -15
echo
echo "=== 字符串 ==="
strings -a "$EFI" 2>/dev/null | head -15
echo
echo "=== UsbPwrCtrlDxe（nuwa/SM8550）在哪被引用 ==="
grep -rn 'UsbPwrCtrlDxe' "$U/Platforms/Xiaomi/fuxiPkg/" 2>/dev/null | head -5 | cut -c1-140
grep -rn 'UsbPwrCtrlDxe' "$U/Silicon/Qualcomm/QcomPkg/Extra.fdf.inc" 2>/dev/null | head -3 | cut -c1-140
