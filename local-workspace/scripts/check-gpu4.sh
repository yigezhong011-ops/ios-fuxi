#!/bin/bash
# Is t32-gpu4.img complete, and does its payload keep the Data seed (compare with t32-bl-daily)?
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/bootimg-sizes.py > /root/fuxi/bis.py
for f in t32-bl-daily t32-gpu4; do
  echo "== $f"
  python3 /root/fuxi/bis.py /mnt/e/DSH-Fuxi/$f.img 2>&1 | head -8
done
