#!/bin/bash
# Read-only: the parse_verb call site and body in t50, frame limits, and where the screenshot provider runs.
R=/root/fuxi/ref-qcomxnuusbdebug/kernel; D=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt; S=/mnt/e/DSH-Fuxi/unixnu-build
dis() { awk -v a="$1" -v b="$2" '$1>=a":" && $1<=b":"' "$D" | cut -c1-84; }
echo '== call site'; dis fffffff00c070ae0 fffffff00c070b40
echo '== parse_verb'; grep -E '_sxnu_control_(parse_verb|verb_name|crc32)$' "$N"
A=$(grep -E '_sxnu_control_parse_verb$' "$N" | cut -d' ' -f1); E=$(printf '%x' $((0x$A + 0x1a0))); dis "$A" "$E"
echo '== callers of parse_verb'; grep -c -E 'bl\s+0x[0-9a-f]+ <_sxnu_control_parse_verb>' "$D"
echo '== limits'; grep -n -E 'SXNU_CONTROL_(FRAME|LINE)_BYTES|SXNU_CONTROL_VERB_[A-Z_]+[, ]*$' $R/QcomUsbControl.h | cut -c1-90 | head -14
echo '== shot in source'; grep -n -E 'SCREENSHOT|shot_start|shot_begin|shot_capture|\.capture|capture\(|shot_cancel' $R/QcomXnuUsbDebug.c | cut -c1-110 | head -16
L=$(grep -n 'case SXNU_CONTROL_VERB_SCREENSHOT\|== SXNU_CONTROL_VERB_SCREENSHOT' $R/QcomXnuUsbDebug.c | head -1 | cut -d: -f1); [ -n "$L" ] && sed -n "$L,$((L+22))p" $R/QcomXnuUsbDebug.c | cut -c1-100
grep -n -E 'capture|state|busy|BUSY|preparing' $R/../include/QcomUsbScreenshot.h | cut -c1-100 | head -24
grep -rln 'qcom_usb_debug_register_screenshot' $R $R/.. 2>/dev/null | grep -v .git | head
echo '== NVT_SLOTS'; grep -n 'NVT_SLOTS' "$S/fuxi/package/TouchProbe.cpp" | head -3 | cut -c1-100
grep -rn 'native_touch_xs\|native_touch_ids' "$S/fuxi/package" "$S/unixnu/drivers" --include='*.cpp' --include='*.c' --include='*.h' 2>/dev/null | cut -c30-150 | head -10
