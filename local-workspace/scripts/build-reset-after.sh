#!/bin/bash
# Build a bisect image on the unmodified touch kernel: reset 6 s after SYMBOL in _arm_init.
# Usage: build-reset-after.sh <out-name> <symbol> [occurrence]
set -euo pipefail
OUT=$1
SYM=$2
OCC=${3:-1}
bash /root/fuxi/patch-panic-fts4.sh "/root/fuxi/pkg-$OUT" --reset-delay 6 --reset-after "$SYM" --occurrence "$OCC" | grep patched
bash /root/fuxi/build-fts3.sh "/root/fuxi/pkg-$OUT/kernel.macho" "unixnu-$OUT" | tail -1
