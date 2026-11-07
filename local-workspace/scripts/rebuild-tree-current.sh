#!/bin/bash
# Rebuild the tree from the current device branch, then generate the stub patch
# against that exact file, so it applies on CI as well.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true
DEV=/root/fuxi/fork-device
OUT=/root/ux3
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
cd "$DEV" && git checkout -q old && git reset -q --hard origin/old

cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
echo "=== 用当前分支建树 ==="
./unixnu defconfig fuxi_gpu_defconfig -D "$DEV" --out "$OUT" --uefi "$UEFI" 2>&1 | tail -1
./unixnu tree -D "$DEV" --out "$OUT" --uefi "$UEFI" 2>&1 | tail -2
echo "树: $OUT/fuxi/tree"
ls "$OUT/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c" && wc -l "$OUT/fuxi/tree/.cache/xnu-work/bsd/kern/bsd_init.c"
