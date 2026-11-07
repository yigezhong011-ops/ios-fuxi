#!/bin/bash
# Read-only: what t50 really wires up for reboot and screenshot; earlier notes; host tools.
E=/mnt/e/DSH-Fuxi; K=/root/fuxi/t50/kernel.macho; S=$E/dump/wsl
echo "=== earlier study scripts"; head -12 $S/study-usbctl.sh | cut -c1-130; grep -rlE 'qcom-usb-ctl|usb-ctl|SCREENSHOT' $E/*.md 2>/dev/null | head
grep -nE 'qcom-usb-ctl|控制通道|SCREENSHOT' $E/*.md 2>/dev/null | cut -c1-200 | head -10
echo "=== callers in t50"
syms=""; for s in _qcom_usb_debug_register_framebuffer _qcom_usb_debug_register_screenshot _qcom_usb_debug_control_start _qcom_usb_debug_control_arm_reboot _qcom_usb_debug_control_take_reboot; do
  a=$(llvm-nm $K | awk -v s=$s '$3==s{print $1}'); echo "$s $a"
done
llvm-objdump -d --macho $K 2>/dev/null > /tmp/k.dis
wc -l /tmp/k.dis
for s in _qcom_usb_debug_register_framebuffer _qcom_usb_debug_register_screenshot _qcom_usb_debug_control_start _qcom_usb_debug_control_arm_reboot _qcom_usb_debug_control_take_reboot; do
  echo "--- bl $s"; grep -E "^(\s*)?[0-9a-f]+.*\bbl\b.*$s\b" /tmp/k.dis | cut -c1-90 | head -5
done
echo "=== PE_halt_restart and args"
llvm-nm $K | grep -E ' _PE_halt_restart$'
grep -a -c 'qcom-usb-reboot' $K
sed -n 600,640p /root/fuxi/ref-qud/kernel/QcomXnuUsbDebug.c | cut -c1-120
echo "=== kernel arg parse for ctl and reboot"
grep -rn 'qcom-usb-ctl\|qcom-usb-reboot' /root/fuxi/ref-qud/kernel /root/fuxi/ref-qud/patches /root/fuxi/fuxi2/scripts 2>/dev/null | cut -c1-140 | head -8
echo "=== real boot: any QUD status text"
L=$(ls -t $E/logs/com3-t50-auto-120clock-p-*.log | head -1)
tr -d '\r' < "$L" | grep -anE 'QCOM|control|usbdebug|QUD' | cut -c1-140 | head -12
