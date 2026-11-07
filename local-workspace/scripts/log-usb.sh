#!/bin/bash
# USB debug console evidence in a decoded sheng log: msgbuf lines and snapshot rows mentioning USB/VBUS/QcomXnuUsbDebug.
B=$1; O=$2
rm -rf "$O"; python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -1
D=$(ls -d "$O"/*/ | head -1)
grep -E 'uptime_s|boot_id' $D/header.txt
echo "### msgbuf"
tr -d '\0' < $D/msgbuf.txt | grep -aiE 'usb|vbus|dwc|xhci|cdc|acm|qcom-usb|FuxiUsb|udc|phy' | sed -E 's/^\[ *[0-9.]+\]: //' | sort | uniq -c | sort -rn | head -30 | cut -c1-200
echo "### snapshot rows"
grep -aiE '^\[usb|^USB|usb' $D/latest.txt | head -15 | cut -c1-200
