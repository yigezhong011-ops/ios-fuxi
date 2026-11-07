#!/bin/bash
# Repair the rewritten submodule in the local device fork, then retry the build.
set -uo pipefail
REPO=/mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain
[ -f "$REPO/env.sh" ] && source "$REPO/env.sh" || true

DEV=/root/fuxi/fork-device
D="$DEV/drivers/QcomXnuUsbDebug"
rm -rf "$D"
git clone -q --depth 1 https://github.com/xiaoleGun/QcomXnuUsbDebug.git "$D"
NEW=$(git -C "$D" rev-parse HEAD)
git -C "$DEV" update-index --add --cacheinfo 160000,"$NEW",drivers/QcomXnuUsbDebug
echo "repointed -> $NEW"
ls "$D" | head -3

OUT=/root/ux2
UEFI=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
cd /mnt/e/DSH-Fuxi/unixnu-build/unixnu || exit 1
LOG=/root/local-build.log
: > "$LOG"

echo "=== stub 归档 ==="
python3 "$DEV/scripts/build-fuxi-link-stubs.py" 2>&1 | tail -2
ls -l "$DEV/build/fuxi-link-stubs/" 2>/dev/null

echo "=== 编内核 ==="
./unixnu build kernel -D "$DEV" --out "$OUT" --uefi "$UEFI" -j"$(nproc)" >>"$LOG" 2>&1
echo "kernel exit=$?"
tail -20 "$LOG"
