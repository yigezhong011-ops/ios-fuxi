#!/bin/bash
# Read-only: the migrator's entry and the attributes it demands.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc
echo "== migrateDataStoreToCurrentVersion"; python3 -I read-store-build.py $D 1ca89d104 360 | grep -v '^{' | cut -c1-125
echo "== isUpToDate head"; python3 -I read-store-build.py $D 1ca89c640 90 | grep -v '^{' | cut -c1-125
echo "== isUpToDate after each conform"; python3 -I read-store-build.py $D 1ca89c7d0 90 | grep -v '^{' | cut -c1-125
python3 -I read-store-strings.py $D 'NSURL|Protection|ExcludedFromBackup|resource' 2>&1 | grep -v '^{' | cut -c1-150 | head -20
strings -a /root/fuxi/sys-peek/dsc/dyld_shared_cache_arm64.0* 2>/dev/null | grep -E '^NSFileProtection|^NSURLFileProtection' | sort -u | head
