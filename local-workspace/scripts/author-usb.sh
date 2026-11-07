#!/bin/bash
# The t32 author's device repository: newest commits on every branch, and everything that mentions USB.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
R=ljhhkx529/unixnu-fuxi
for b in $(api "$R/branches" | python3 -c 'import json,sys; [print(b["name"]) for b in json.load(sys.stdin)]'); do
  echo "### branch $b"
  api "$R/commits?sha=$b&per_page=6" | python3 -c 'import json,sys; [print("  ", c["sha"][:9], c["commit"]["committer"]["date"][:16], c["commit"]["message"].splitlines()[0][:100]) for c in json.load(sys.stdin)]'
done
echo "### USB files on old"
api "$R/git/trees/old?recursive=1" | python3 -c '
import json,sys
for e in json.load(sys.stdin)["tree"]:
    p = e["path"]
    if any(k in p.lower() for k in ("usb", "dwc", "vbus", "typec", "pmic-usb", "cdc")):
        print("  ", e["type"], p)'
echo "### .gitmodules (USB driver source)"
curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/$R/old/.gitmodules" | grep -i -A2 usb
