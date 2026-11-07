#!/bin/bash
# Read-only: the author's phone identity code and board notes, and the lines around the iPhone10,3 log hits.
cd /root/fuxi/ref-fuxi-v2 || exit 1
git show origin/old:board.toml | sed -n 218,240p | cut -c1-280
echo ======
git show origin/old:scripts/make-fuxi-adt.py > /tmp/mfa.py
grep -n -A14 '^PHONE_MODELS' /tmp/mfa.py | cut -c1-170
sed -n 146,175p /tmp/mfa.py | cut -c1-200
grep -n -E "identity\[|identity\.get|display-scale|artwork|compatible-device|thin-bezel|home-button|button-names|island" /tmp/mfa.py | cut -c1-170
echo ======
git log origin/old -3 --format='%h %ad %s' --date=short -- board.toml scripts/make-fuxi-adt.py | cut -c1-110
git log origin/old --format='%h %ad %s' --date=short -i --grep='subtype\|red bar\|status' | cut -c1-110 | head
echo ======
grep -a -n -F -B3 -A3 'iPhone10,3' /mnt/e/DSH-Fuxi/logs/carve-iphonex-first/lscan.txt | cut -c1-170 | head -24
