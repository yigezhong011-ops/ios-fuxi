#!/bin/bash
# Read-only: USB control verbs in the t50 kernel, and where touch samples enter the HID path.
K=/root/fuxi/t50/kernel.macho; N=/tmp/t50-syms.txt; S=/mnt/e/DSH-Fuxi/unixnu-build
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
echo '== usb debug symbols'; grep -E 'qcom_usb_debug|QcomXnuUsbDebug|usb_control|usb_ctl' "$N" | grep -v -E 'MetaClass|ktv|__ZTV' | cut -c1-100 | head -24
echo '== verb strings'; strings -a "$K" | grep -E '^(HELLO|SCREENSHOT|SHOTNEXT|REBOOT|REBOOT-FASTBOOT|STATUS|PING|LOG[A-Z]*|TOUCH|TAP)$' | sort -u | head
strings -a -t x "$K" | grep -E ' (SCREENSHOT|SHOTNEXT)$' | head -4
echo '== touch symbols'; grep -iE 'touch|hid_static|native_hid|NativeHid' "$N" | grep -v -E 'MetaClass|ktv|__ZTV|IOHID[A-Z]' | cut -c1-100 | head -24
echo '== source'
grep -n -E 'seq|Finger|publish|register|struct ' "$S/fuxi/package/TouchProbe.cpp" | sed -n 1,4p | cut -c1-120
sed -n 34,44p "$S/fuxi/package/TouchProbe.cpp" | cut -c1-150
sed -n 325,345p "$S/fuxi/package/TouchProbe.cpp" | cut -c1-150
grep -n -E 'touchPublish|publishFingers|shengTouch|sheng_touch|gTouch[A-Z][a-z]+\s*[=(]' "$S/fuxi/package/TouchProbe.cpp" | cut -c1-120 | head -12
ls /root/fuxi/ref-qcomxnuusbdebug 2>/dev/null | head -12
grep -n -E '"(SCREENSHOT|SHOTNEXT|REBOOT|STATUS)"|strcmp|strncmp|verb' /root/fuxi/ref-qcomxnuusbdebug/*.c* 2>/dev/null | cut -c30-140 | head -14
