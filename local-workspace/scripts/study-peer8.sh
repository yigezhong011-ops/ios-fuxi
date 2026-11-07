#!/bin/bash
# Read-only: which boot wrote the log window, and what happened around a REBOOT in it.
D=$(ls -d /root/fuxi/hang/peer-boot1/*/ | head -1); cd "$D"; ls -la
M=$(ls -S | head -1); echo "largest: $M"
for f in *; do echo "--- $f"; head -c 500 "$f" | strings -n 4 | head -6 | cut -c1-140; done
echo "== build/version"; grep -a -h -m3 -E 'Darwin Kernel Version|boot-args|Boot args|FUXI IOS17' * | cut -c1-200
echo "== reboot/usb lines"; grep -a -h -n -E 'qud|QUD|reboot|REBOOT|PE_halt|queued|hook' * | cut -c1-150 | tail -25
echo "== panic"; grep -a -h -n -i -E 'panic' * | cut -c1-170 | head -15
echo "== tail"; tail -n 20 "$M" | cut -c1-170
