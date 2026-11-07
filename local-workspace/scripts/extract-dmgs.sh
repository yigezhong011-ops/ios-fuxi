#!/bin/bash
set -euo pipefail
I=/mnt/e/DSH-Fuxi/dump/iphonex-16.7.11.ipsw
W=/root/fuxi/build-x
mkdir -p "$W"
cd "$W"
echo "=== 解压 OS.dmg (087-86698, 4.73 GB) ==="
unzip -o -j "$I" '087-86698-034.dmg' -d "$W" >/dev/null
mv -f 087-86698-034.dmg OS.dmg 2>/dev/null || true
echo "=== 解压 SystemOS.dmg (087-86593, 2.74 GB) ==="
unzip -o -j "$I" '087-86593-037.dmg' -d "$W" >/dev/null
mv -f 087-86593-037.dmg SYSTEMOS.dmg 2>/dev/null || true
echo "=== 解压 AppOS.dmg (087-86715, 10 MB) ==="
unzip -o -j "$I" '087-86715-037.dmg' -d "$W" >/dev/null
mv -f 087-86715-037.dmg APPOS.dmg 2>/dev/null || true
ls -lh "$W"/*.dmg
