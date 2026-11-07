#!/bin/bash
# Build a bisect image on the serial-stubbed touch kernel: reset 6 s after SYMBOL in _arm_init.
# Usage: build-stub-reset.sh <out-name> <symbol> [occurrence]
set -euo pipefail
OUT=$1
SYM=$2
OCC=${3:-1}
bash /root/fuxi/patch-panic-fts4.sh "/root/fuxi/pkg-$OUT" --reset-delay 6 --reset-after "$SYM" --occurrence "$OCC" | grep patched
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/patch-serial-init-ret0.py "/root/fuxi/pkg-$OUT/kernel.macho"
bash /root/fuxi/build-fts3.sh "/root/fuxi/pkg-$OUT/kernel.macho" "unixnu-$OUT" | tail -1
