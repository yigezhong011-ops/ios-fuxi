#!/bin/bash
# Read-only: the empty checkpoint, the PE_Video use, the capture path limits and the reply formats in the t50 kernel.
set -u
A=/root/fuxi/t50.dis; K=/root/fuxi/t50/kernel.macho; N=/tmp/t50-syms.txt; Q=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/drivers/QcomXnuUsbDebug
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
r() { awk -v a="$1" -v b="$2" '{k=substr($1,1,16)} k>=a && k<=b' "$A" | cut -c1-100; }
echo '== checkpoint'; r fffffff00c01f8e4 fffffff00c01f8f0
grep -n -E 'bl?\s+0xfffffff00c01f8e4' "$A" | cut -c1-100 | head
echo '== PE_current_console use'; r fffffff00c01d39c fffffff00c01d3c8
awk 'index($0,"<_PE_current_console>:"){p=1} p{print; c++} p&&/^$/{exit} c>25{exit}' "$A" | cut -c1-90
echo '== console struct in source'; grep -n -A14 'struct PE_Video' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/../unixnu/../fuxi/package/*.h 2>/dev/null | head -2
echo '== capture'; awk 'index($0,"<_qcom_usb_shot_capture>:"){p=1} p{print; c++} p&&/^$/{exit} c>36{exit}' "$A" | cut -c1-100
grep -E ' _?(pixels|image|qcom_usb_shot_[a-z_]*|provider[a-z_]*)$' "$N" | cut -c1-70
echo '== reply strings'; strings -a "$K" | grep -E 'state=|SHOTNEXT' | cut -c1-140 | sort -u | head -14
grep -n -E 'QUD_SCREENSHOT_CHUNK|define QUD' "$Q/kernel/"*.h "$Q/include/QcomUsbScreenshot.h" | cut -c1-110 | head
grep -n -E 'SHOTNEXT|offset=|state=' "$Q/kernel/QcomXnuUsbDebug.c" | cut -c1-140 | head -14
grep -n -E 'def control_reply|def .*shot|offset|SHOTNEXT' "$Q/scripts/xnu_usb_control.py" | cut -c1-120 | head -14
which clang ld.lld llvm-objcopy llvm-mc 2>/dev/null
python3 -c 'import serial; print("wsl pyserial ok")' 2>&1 | tail -1
