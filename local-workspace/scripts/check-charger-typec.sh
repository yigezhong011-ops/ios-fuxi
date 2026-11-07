#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
D=$U/Binaries/nuwa/QcomPkg/Drivers
echo "=== nuwa 里的充电器 / TypeC / PMIC / SPMI 驱动 ==="
ls "$D" 2>/dev/null | grep -iE 'charg|typec|type-c|pmic|spmi|vbus|smb|qpnp' | head -25
echo
echo "=== 这些驱动在 fuxi 的 inc 里被加载了吗 ==="
grep -n -iE 'charg|typec|pmic|spmi' "$U/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" \
  "$U/Platforms/Xiaomi/fuxiPkg/Include/APRIORI.inc" 2>/dev/null | cut -c1-130 | head -20
echo
echo "=== UsbPwrCtrlDxe 里引用的协议（strings）==="
strings -a "$D/UsbPwrCtrlDxe/UsbPwrCtrlDxe.efi" 2>/dev/null | grep -iE 'charg|typec|pmic|spmi|vbus|protocol|%a' | head -15 | cut -c1-120
