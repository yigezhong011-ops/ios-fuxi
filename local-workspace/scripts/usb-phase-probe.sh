#!/bin/bash
# USB debug state symbols in the t36 kernel, and which kernel statistics the sheng log already exports (so a copied value shows up).
K=/root/fuxi/t36/kernel.macho
llvm-nm --defined-only $K | grep -iE 'fuxi_usbdbg|qcom_usb_debug|qud_|usb_status|native_backlight_stats|native_cpufreq_row|native_cpufreq_stage' | head -30
echo "### decoder rows that print kernel stat arrays"
grep -nE "backlight|cpufreq|ext\]|'X[0-9]|def .*row|\[clocks\]|\[usb" /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py | head -30
echo "### does the USB-test log show the cpufreq/backlight rows?"
D=$(ls -d /root/fuxi/logs-usb/*/ | head -1)
grep -nE '^\[clocks\]|^X[0-9]|^\[ext\]|^BL |^BTN ' $D/latest.txt | head -12
