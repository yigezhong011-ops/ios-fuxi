#!/bin/bash
# How socrates (SM8550, the QcomXnuUsbDebug source device) leaves USB in DEVICE mode for XNU: find its repositories and
# the UEFI side of the USB handoff.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/$1"; }
echo "### repositories named *socrates*"
api 'search/repositories?q=socrates+unixnu&per_page=10' | python3 -c 'import json,sys; [print(" ", r["full_name"], r["pushed_at"][:10], (r["description"] or "")[:80]) for r in json.load(sys.stdin)["items"]]'
api 'search/repositories?q=uefi-socrates&per_page=10' | python3 -c 'import json,sys; [print(" ", r["full_name"], r["pushed_at"][:10], (r["description"] or "")[:80]) for r in json.load(sys.stdin)["items"]]'
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
for q in 'socrates UsbConfigDxe' 'PcdUsbDefaultRole' 'UsbfnDwc3Dxe "DEVICE"' 'socrates-usb-log'; do
  echo "### code: $q"; python3 /root/fuxi/cs.py "$q" | head -8; sleep 3
done
