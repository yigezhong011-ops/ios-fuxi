#!/bin/bash
set -uo pipefail
W=/root/fuxi/t36-usb-log3
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > /root/fuxi/t36-log3.toml 2>/dev/null
echo "=== 关键设置 ==="
grep -nE '^tools|^title|^\[|panic_screen|skip_setup' /root/fuxi/t36-log3.toml | head -12 | cut -c1-120
echo
echo "=== args ==="
grep -o 'args = "[^"]*"' /root/fuxi/t36-log3.toml | sed 's/^args = "//; s/"$//' | tr ' ' '\n' | grep -nE 'usb|serial|debug|setup|backlight' 
echo
echo "=== 固件里确认有 AdvancedLogDxe（Tools 插件） ==="
FD=/root/build/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
ls /root/build/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/Ffs/ 2>/dev/null | grep -i 'AdvancedLog\|LogView' | head -5
