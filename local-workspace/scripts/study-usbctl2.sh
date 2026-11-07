#!/bin/bash
# Read-only: USB control docs and how sheng returns to fastboot.
D=/root/build/fuxi/drivers/QcomXnuUsbDebug
cut -c1-420 $D/docs/control-and-screenshot.md | head -110
echo "=== collect flags"; grep -n -E 'add_argument' $D/scripts/*.py | cut -c1-210 | head -30; ls $D/scripts $D/userland | head -30
echo "=== t50 control syms"; llvm-nm --defined-only /root/fuxi/t50/kernel.macho | grep -E 'qcom_usb_debug_control|screenshot|qcom_usb_start_reboot|qcom_usb_reboot' | cut -c18- | head -20
echo "=== reset"; S=/root/fuxi/ref-sad-fuxi; ls $S/package | grep -i -E 'reset|button' ; F=$S/package/BootResetCore.h; [ -f $F ] && sed -n 1,60p $F | cut -c1-200
grep -rIl -E 'reboot.?mode|SDAM|sdam|bootloader_mode|fastboot' $S/package 2>/dev/null | head;
grep -n -E 'reboot-mode|mode-bootloader|sdam|nvmem-reboot' /root/fuxi/fuxi-stock.dts | cut -c1-120 | head -12
llvm-nm --defined-only /root/fuxi/t50/kernel.macho | grep -i -E 'boot_reset|BootReset|reset_to|sheng_reset|fastboot|pm_silent|PEHaltRestart$' | cut -c18- | head -14
