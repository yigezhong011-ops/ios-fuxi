#!/bin/bash
# Populate the missing submodules of the firmware tree, then build the firmware the way
# the documentation says: ./unixnu build firmware --uefi <dir>
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
TREE=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
LOG=/root/uefi-build.log
: > "$LOG"

echo "=== 子模块状态 ===" | tee -a "$LOG"
cd "$U" || exit 1
git config --unset submodule.Silicium-ACPI.update 2>/dev/null || true
git submodule status 2>/dev/null | cut -c1-100 | head -8 | tee -a "$LOG"

echo "=== 初始化缺失的子模块 ===" | tee -a "$LOG"
git submodule update --init --depth 1 Silicium-ACPI >>"$LOG" 2>&1
echo "    exit=$?" | tee -a "$LOG"
ls "$U/Silicium-ACPI/Platforms" 2>/dev/null | head -3 | tee -a "$LOG"

echo "=== ./unixnu build firmware ===" | tee -a "$LOG"
cd "$TREE" || exit 1
./unixnu defconfig fuxi_full_defconfig -D "$DEV" >>"$LOG" 2>&1
./unixnu build firmware -D "$DEV" --uefi "$U" --target DEBUG >>"$LOG" 2>&1
echo "=== $(date) 结束 exit=$? ===" | tee -a "$LOG"
tail -30 "$LOG"
