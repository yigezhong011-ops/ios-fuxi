#!/bin/bash
# Read-only: last slots of a hang boot; rows X5/X6 and the Z row; end of msgbuf.
L=${1:-hanglog-hang}
D=$(ls -dt /root/fuxi/hang/$L/*/ | head -1); echo "$D"
grep -E 'boot_id|uptime_s|slots_written|rounds|write_errors|state=' $D/header.txt
echo "== slot timeline"; grep -a -E '^#slot' $D/slots.txt | tail -8
echo "== latest.txt (start)"; head -n 40 $D/latest.txt | cut -c1-150
echo "== X/Z/S/P rows by slot, changes only"
awk '/^#slot/{s=$2" "$3; next} /^(X[0-9]+|Z[0-9]+|[A-Z][0-9]* )/{print s" | "$0}' $D/slots.txt | cut -c1-120 | awk -F' \\| ' '!seen[$2]++' | tail -45
echo "== msgbuf tail"; tail -n 30 $D/msgbuf.txt | cut -c1-170
echo "== panic / launchd words"; grep -a -c -i 'panic' $D/msgbuf.txt; grep -a -n -E 'launchd|root device|BSD root|sheng|Z[0-9]/' $D/msgbuf.txt | cut -c1-130 | tail -12
