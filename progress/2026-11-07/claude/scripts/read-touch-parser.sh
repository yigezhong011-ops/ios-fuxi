#!/bin/bash
# Read-only: the control line path in the reference source and in the t50 disassembly.
R=/root/fuxi/ref-qcomxnuusbdebug/kernel; D=/root/fuxi/t50.dis
echo '== QcomUsbControl.h'
sed -n 30,76p $R/QcomUsbControl.h | cut -c1-100
sed -n 155,188p $R/QcomUsbControl.h | cut -c1-100
sed -n 244,272p $R/QcomUsbControl.h | cut -c1-100
echo '== callers in QcomXnuUsbDebug.c'
grep -n -E 'sxnu_control_parser_feed|sxnu_control_parse\(|sxnu_control_accept|sxnu_control_commit|screenshot_capture|->capture|\.capture|provider|control_handle|control_process|control_service|control_poll' $R/QcomXnuUsbDebug.c | cut -c1-110 | head -30
L=$(grep -n 'sxnu_control_parser_feed' $R/QcomXnuUsbDebug.c | head -1 | cut -d: -f1)
echo "== source around feed ($L)"; sed -n "$((L-30)),$((L+70))p" $R/QcomXnuUsbDebug.c | cut -c1-100
echo '== t50: bytes compared with SXNU header and verbs'
awk '/^fffffff00c06[e-f]|^fffffff00c07/ && /cmp.*#0x53$|ccmp.*#0x58|#0x58,|#0x4e,|mov.*#0x4e55|mov.*#0x5853/' $D | cut -c1-80 | head -20
echo '== t50: bl targets from the control range'
awk '/^fffffff00c06(e|f)|^fffffff00c070/ && /\tbl\t/' $D | sed -E 's/^(f+[0-9a-f]+):\s+bl\s+0x[0-9a-f]+ /\1 /' | cut -c1-80 | awk '{print}' | head -90
