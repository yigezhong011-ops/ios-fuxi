#!/bin/bash
# fuxi's physical keys in the stock device tree: the gpio_keys node (volume up), the PON node (power / RESIN = volume down)
# and the SPMI arbiter, so a button driver can be pointed at the right peripherals.
DTS=/root/fuxi/fuxi-live.dts
echo "== gpio-keys"
awk '/gpio[-_]keys[ \t]*\{/{f=1} f{print NR": "$0} f&&/^\t*\};/{if(++n>=6)exit}' "$DTS" | head -45
echo "== pon / resin / pwrkey nodes"
grep -n -E 'qcom,pm8550-pon|qcom,pmk8350-pon|pon_pwrkey|pon_resin|qcom,pmk8350-pwrkey|qcom,pmk8350-resin|linux,code = <0x7[23]>|linux,code = <0x74>' "$DTS" | head -20
echo "== spmi arbiter"
grep -n -E 'spmi@|qcom,spmi-pmic-arb|qcom,ee|qcom,channel' "$DTS" | head -10
