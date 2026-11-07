#!/bin/bash
# How do other UniXNU ports wire the PMIC power / volume keys, and does the t32 kernel carry any PMIC (SPMI/PON) code?
echo "== device records mentioning PON / power or volume buttons"
grep -h -o -E '[^"]{0,160}(\bPON\b|[Pp]ower button|[Vv]olume (button|key)|kpdpwr|KPDPWR|RESIN)[^"]{0,200}' \
  /root/fuxi/uni-oddly/docs/.vitepress/device-records/*.toml | head -12
echo "== t32 kernel strings"
grep -a -o -E '[ -~]{0,50}(spmi|SPMI|kpdpwr|KPDPWR|resin)[ -~]{0,60}' /root/fuxi/t32/kernel.macho | sort -u | head -15
