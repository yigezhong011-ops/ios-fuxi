#!/bin/bash
# The step recorder with a shorter delay readout: 2 s per step, 20 s at most. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl; E=/mnt/e/DSH-Fuxi
tr -d '\r' < $S/patch-loader-marker4.py > /tmp/plm4.py
STEP_SECS=2 python3 -I /tmp/plm4.py $E/t50-auto-hanghigh.img $E/t50-auto-marker5.img | tail -1
aarch64-linux-gnu-objdump -D -b binary -m aarch64 --start-address=0x2f002c --stop-address=0x2f0038 /tmp/marker4-body.bin | tail -n +8 | cut -c1-72
sha256sum $E/t50-auto-marker5.img | cut -c1-16
