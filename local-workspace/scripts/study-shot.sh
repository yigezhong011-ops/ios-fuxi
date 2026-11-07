#!/bin/bash
# Read-only: what t50 offers for the USB screenshot. The registration functions, the framebuffer the display driver keeps, and GOP symbols.
K=/root/fuxi/t50/kernel.macho; Q=/root/fuxi/ref-qud; G=/root/fuxi/ref-gopfb
dis() { local a=$(llvm-nm $K | awk -v s=$1 '$3==s{print $1}'); [ -z "$a" ] && { echo "no $1"; return; }; echo "--- $1 $a"; llvm-objdump -d --start-address=0x$a --stop-address=$(printf '0x%x' $((0x$a + $2))) $K 2>/dev/null | tail -n +7 | cut -c19-96; }
llvm-nm $K | grep -E 'qcom_usb.*(screenshot|framebuffer)|shot_|gShot|NativeGOPPresenter|native_gop|gop_' | cut -c1-110 | head -40
dis _qcom_usb_debug_register_framebuffer 0xb0
sed -n '/struct qcom_usb_framebuffer/,/};/p' $Q/include/QcomXnuUsbDebug.h | cut -c1-90
echo "=== does GopFramebuffer register"; grep -rn -E 'qcom_usb_debug_register|register_screenshot|register_framebuffer' $G $Q/docs 2>/dev/null | cut -c1-140 | head
grep -rn -E 'fbVA|frameBuffer|mVirt|scanoutVa|mappedBase|fbBase|_mapped|mapDeviceMemory' $G/*.cpp $G/*.h 2>/dev/null | cut -c1-140 | head -24
ls $G | head -20
