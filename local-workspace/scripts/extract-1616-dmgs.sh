#!/bin/bash
set -euo pipefail
I=/mnt/e/DSH-Fuxi/dump/iphonex-16.7.16.ipsw
W=/root/fuxi/build-1616
mkdir -p "$W"
cd "$W"
unzip -o -j "$I" '087-86698-044.dmg' -d "$W" >/dev/null && mv -f 087-86698-044.dmg OS.dmg
unzip -o -j "$I" '087-86593-047.dmg' -d "$W" >/dev/null && mv -f 087-86593-047.dmg SYSTEMOS.dmg
unzip -o -j "$I" '087-86715-047.dmg' -d "$W" >/dev/null && mv -f 087-86715-047.dmg APPOS.dmg
ls -lh "$W"/*.dmg
