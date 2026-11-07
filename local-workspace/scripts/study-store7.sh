#!/bin/bash
# Read-only: the data store migrator, named call sites only.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc
python3 -I read-store-build.py $D 1ca89c600 2400 | grep -v '^{' | cut -c1-125 | grep -E '; |\bret\b|pacibsp' | sed -E 's/\s+x[0-9]+, x[0-9]+, #0x[0-9a-f]+//' | head -230
