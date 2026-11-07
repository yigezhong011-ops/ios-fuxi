#!/bin/bash
# The [clocks] rows of a decoded log (where USB_DIAG writes "USB p.. r.. n.."), counted, plus the newest snapshot's row.
D=$(ls -d "$1"/*/ | head -1)
grep -h '^\[clocks\]' "$D/slots.txt" | sed -E 's/ n[0-9a-f]+$//' | sort | uniq -c | tail -8
echo "### newest"; grep -h '^\[clocks\]' "$D/latest.txt"
grep -E 'uptime_s' "$D/header.txt"
