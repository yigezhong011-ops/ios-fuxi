#!/bin/bash
# Fetch the fuxi USB debug glue and the QcomXnuUsbDebug driver docs/sources into E:\DSH-Fuxi\read\usb (read-only reference).
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
D=/mnt/e/DSH-Fuxi/read/usb; mkdir -p $D; cd $D
raw() { curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/$1" -o "$2"; }
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
raw ljhhkx529/unixnu-fuxi/old/package/FuxiUsbCompat.c FuxiUsbCompat.c
raw ljhhkx529/unixnu-fuxi/old/patches/xnu/zzzd-fuxi-usb-debug.patch zzzd-fuxi-usb-debug.patch
raw ljhhkx529/unixnu-fuxi/old/scripts/build-fuxi-usb-debug.py build-fuxi-usb-debug.py
SHA=$(api "ljhhkx529/unixnu-fuxi/contents/drivers/QcomXnuUsbDebug?ref=old" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])')
echo "QcomXnuUsbDebug pinned at $SHA"
api "xiaoleGun/QcomXnuUsbDebug/git/trees/$SHA?recursive=1" | python3 -c 'import json,sys; [print(e["path"]) for e in json.load(sys.stdin)["tree"] if e["type"]=="blob"]' > files.txt
cat files.txt | head -60
for f in $(grep -iE '\.md$|boundar|vbus|phy|dwc|\.c$|\.h$' files.txt | head -30); do mkdir -p "qxud/$(dirname $f)"; raw "xiaoleGun/QcomXnuUsbDebug/$SHA/$f" "qxud/$f"; done
wc -l FuxiUsbCompat.c qxud/*.md qxud/**/*.md 2>/dev/null | tail -5
