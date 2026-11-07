#!/bin/bash
B=/mnt/e/DSH-Fuxi/logs/twrp-gpu2.bin; O=/root/fuxi/log-gpu2
rm -rf "$O"; python3 -I /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts/read-sheng-log.py --decode "$B" --out "$O" 2>&1 | tail -1 | cut -c1-160
python3 /mnt/e/DSH-Fuxi/dump/wsl/decode-gpu2-log.py "$O"
