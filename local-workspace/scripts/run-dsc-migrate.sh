#!/bin/bash
# Read-only: the poster data store's version constants and migration strings in the PosterBoard framework.
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
cd $S
python3 -I read-dsc-build.py $D 2>&1 | grep -v '^{' | cut -c1-140 | tail -70
echo "== xrefs"
python3 -I read-dsc-xref.py $D x 'Pre-migration; data store never ever initialized' 'Pre-migration data store version' 'Post-migration data store version' 'no idea what this data store is' 2>&1 | tail -8 | cut -c1-170
