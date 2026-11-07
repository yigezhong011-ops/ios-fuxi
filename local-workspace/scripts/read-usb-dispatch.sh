#!/bin/bash
# Read-only: how the USB control channel dispatches verbs, in the reference source and in t50.
R=/root/fuxi/ref-qcomxnuusbdebug; D=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt; K=/root/fuxi/t50/kernel.macho
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
echo '== ref files'; find "$R" -type f | grep -v '/.git/' | head -30
echo '== ref grep'; grep -rn -E 'SXNU1|"HELLO"|"PING"|"STATUS"|"REBOOT"|control_arm_reboot|HELLO' "$R" --include='*' 2>/dev/null | grep -v '/.git/' | cut -c1-150 | head -30
echo '== symbols near control'
grep -E ' [tTdDsSbB] ' "$N" | awk '$1>="fffffff00c06d000" && $1<="fffffff00c071000"' | sort | cut -c1-90
echo '== callers'
for s in _control_arm_reboot _control_take_reboot _qcom_usb_debug_control_start _register_screenshot; do echo "-- $s"; grep -n -E "\bbl?\s+0x[0-9a-f]+ <$s>" "$D" | cut -c1-80 | head -6; done
