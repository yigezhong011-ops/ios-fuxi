#!/bin/bash
set -uo pipefail
K=/root/rebuild/kernel-daily.macho
echo "=== VBUS / QSCRATCH 相关 ==="
for pat in QSCRATCH vbus VBUS 'HS_PHY_CTRL' 'qcom_usb_debug' 'usb_debug'; do
  n=$(strings -a "$K" 2>/dev/null | grep -c -i -- "$pat" || true)
  printf '%-16s %s\n' "$pat" "$n"
done
echo
echo "=== 具体字符串 ==="
strings -a "$K" 2>/dev/null | grep -iE 'vbus|qscratch|hs_phy|qcom.*usb.*debug' | sort -u | head -25 | cut -c1-140
