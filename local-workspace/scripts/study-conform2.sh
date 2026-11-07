#!/bin/bash
# Read-only: the rest of the up-to-date check, then every method in PosterBoardServices that calls the URL resource getters.
cd /mnt/e/DSH-Fuxi/dump/wsl
D=/root/fuxi/sys-peek/dsc
tr -d '\r' < read-store-build.py > /tmp/rsb.py
python3 -I /tmp/rsb.py $D 1ca89c754 2e0 2>/dev/null | grep -v '^{' | cut -c1-100 | grep -E 'bl\s|ret|tbz|tbnz|cbz|cbnz|"|NS' | head -70
echo "=== conform impl search"
python3 -I /tmp/rsb.py $D 1a82cd000 1200 2>/dev/null | grep -v '^{' | grep -E 'resourceValue|getResourceValue|fileExists|allKeys|enumerateKeys|isEqual|Conform|Reachable|checkResource' | cut -c1-100 | head -30
