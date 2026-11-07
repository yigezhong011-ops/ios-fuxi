#!/bin/bash
# Read-only: how migration starts from nothing, and the SQLite database object's init and setup.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc
echo "== migrateDataStoreAtBaseURL head"; python3 -I read-store-build.py $D 1ca89df30 e0 | grep -v '^{' | cut -c1-118
echo "== sqlite db init, named"; python3 -I read-store-build.py $D 1ca8d6c40 480 | grep -v '^{' | cut -c1-118 | grep -E '; |\bret\b|\bcbz|\bcbnz|tbz|tbnz|cmp|\bb\s+0x|\bb\.' | head -90
echo "== setup"; python3 -I read-store-build.py $D 1ca8d8600 300 | grep -v '^{' | cut -c1-118 | grep -E '; |\bret\b|\bcbz|\bcbnz|tbz|tbnz' | head -50
