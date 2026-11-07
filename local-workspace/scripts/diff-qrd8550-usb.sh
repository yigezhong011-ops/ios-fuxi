#!/bin/bash
set -uo pipefail
U=/root/build/uefi-fuxi
echo "=== qrd8550（参考 SM8550 平台）加载的 USB 相关驱动 ==="
grep -nE 'Usb|UCDxe' "$U/Platforms/Qualcomm/qrd8550Pkg/Include/DXE.inc" 2>/dev/null | cut -c1-120
echo
echo "=== qrd8550 APRIORI ==="
grep -nE 'Usb|UCDxe' "$U/Platforms/Qualcomm/qrd8550Pkg/Include/APRIORI.inc" 2>/dev/null | cut -c1-120
echo
echo "=== fuxi 与 qrd8550 的 USB 驱动集合差异 ==="
comm -13 \
  <(grep -oE '[A-Za-z0-9]+/(Drivers/)?[A-Za-z0-9]*Usb[A-Za-z0-9]*\.inf|Usb[A-Za-z0-9]*\.inf' "$U/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" | sed 's#.*/##' | sort -u) \
  <(grep -oE '[A-Za-z0-9]*Usb[A-Za-z0-9]*\.inf' "$U/Platforms/Qualcomm/qrd8550Pkg/Include/DXE.inc" | sort -u) \
  | sed 's/^/  qrd 有、fuxi 没有: /'
echo
echo "=== qrd8550 的 FDF 里 USB 配置/FFS 文件 ==="
grep -nE 'UsbConfig|UsbCfg|QcomUsb' "$U/Platforms/Qualcomm/qrd8550Pkg/"*.fdf "$U/Platforms/Qualcomm/qrd8550Pkg/Include/"*.inc 2>/dev/null | head -14 | cut -c1-140
