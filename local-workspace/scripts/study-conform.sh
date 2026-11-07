#!/bin/bash
# Read-only: who checks NSURLFileProtectionKey on the store. 1: the code around the conform attributes. 2: the up-to-date check.
cd /mnt/e/DSH-Fuxi/dump/wsl
D=/root/fuxi/sys-peek/dsc
tr -d '\r' < read-store-build.py > /tmp/rsb.py
echo "=== around the conform attributes"
python3 -I /tmp/rsb.py $D 1a82cda20 240 2>/dev/null | grep -v '^{' | cut -c1-110 | grep -E 'bl|ret|objc|sel|"|NS' | head -40
echo "=== up-to-date check"
python3 -I /tmp/rsb.py $D 1ca89c5e0 180 2>/dev/null | grep -v '^{' | cut -c1-110 | grep -E 'bl|ret|objc|sel|"|NS' | head -50
echo "=== strings"
tr -d '\r' < read-store-strings.py > /tmp/rss.py
python3 -I /tmp/rss.py $D 'pbf_URLIsReachable|URLIsReachableAndConform' 2>/dev/null | cut -c1-140 | head -8
