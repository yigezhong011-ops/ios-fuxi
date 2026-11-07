#!/bin/bash
# Read-only: buildDataStoreForURL and the head of the store init.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc
python3 -I read-store-build.py $D 1ca914ae0 c0 | grep -v '^{' | cut -c1-130
echo =====
python3 -I read-store-build.py $D 1ca834c60 170 | grep -v '^{' | cut -c1-130
