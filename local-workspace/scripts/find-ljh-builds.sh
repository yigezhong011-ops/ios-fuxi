#!/bin/bash
# Look for published images/artifacts of the t32 author's newer builds (read-only)
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-builds.py > /root/fuxi/gb.py
for r in ljhhkx529/unixnu-fuxi ljhhkx529/fuxi-device SadNutWall/unixnu-fuxi; do
    echo "== $r"; python3 /root/fuxi/gb.py "$r"
done
echo "== SadNutWall repos"; python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-user-repos.py SadNutWall
