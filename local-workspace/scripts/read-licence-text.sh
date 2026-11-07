#!/bin/bash
# Read only: the licence text used by unixnu-ci, and whether the trees the upload needs still exist.
T=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
curl -fsS -H "Authorization: Bearer $T" -H 'Accept: application/vnd.github.raw' https://api.github.com/repos/yigezhong011-ops/unixnu-ci/contents/LICENSE
echo; echo '== trees'
for d in /root/fuxi/ios-fuxi /root/fuxi/fw/fuxi /root/fuxi/fw/unixnu /root/fuxi/fw/uefi-fuxi /root/fuxi/amp-try/x /root/fuxi/plugin-try; do [ -d "$d/.git" ] || [ -f "$d/.git" ] && echo "ok $d" || echo "MISSING $d"; done
echo '== other dirs'
cd /mnt/e/DSH-Fuxi; for d in PATCH-fuxi-usb-power ci gpu-re mesa-ios share-brightness share-for-author unixnu; do [ -d "$d" ] && echo "ok $d" || echo "MISSING $d"; done
echo '== ios-fuxi'
git -c safe.directory='*' -C /root/fuxi/ios-fuxi status --short | head -5
git -c safe.directory='*' -C /root/fuxi/ios-fuxi log --oneline -2 | cut -c1-90
