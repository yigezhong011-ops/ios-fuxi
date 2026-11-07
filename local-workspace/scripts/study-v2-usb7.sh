#!/bin/bash
# Read-only: V2 USB adapter, other V2 docs, AMP and cpufreq on V2, and the t50 kernel's USB symbols for comparison.
cd /root/fuxi/ref-fuxi-v2 || exit 1
V=origin/V2
echo "=== FuxiUsbCompat.c on V2 ($(git show $V:package/FuxiUsbCompat.c | wc -l) lines)"; git show $V:package/FuxiUsbCompat.c | sed -n 1,75p | cut -c1-150
echo "=== prepare diff"; git show 172a8ce -- scripts/prepare-fuxi-usb-debug.py | grep -E '^[+-]' | cut -c1-150 | head -75
echo "=== board and defconfig diff"; git show 172a8ce -- board.toml configs/fuxi_defconfig | grep -E '^[+-]' | cut -c1-220
echo "=== submodule"; git show $V:.gitmodules | grep -A2 -i usb | cut -c1-110; git ls-tree $V drivers/QcomXnuUsbDebug | cut -c1-70
echo "=== AMP cpufreq on V2"
git ls-tree -r --name-only $V | grep -iE 'amp|cpufreq' | head
git grep -nE 'cluster-type|sheng-cpufreq|CONFIG_SCHED_EDGE|amp\.patch' $V -- board.toml configs dts patches/xnu/series porting.toml | sed "s#$V:##" | cut -c1-170 | head -14
echo "=== UNDO.md status"; git show $V:docs/UNDO.md | cut -c1-170 | sed -n 1,28p
echo "=== PORTING_COMPARISON_PLAN headings"; git show $V:docs/PORTING_COMPARISON_PLAN.md | grep -E '^#' | cut -c1-110 | head -24
echo "=== porting.toml usb"; git grep -n -i -A3 'usb' $V -- porting.toml | sed "s#$V:##" | cut -c1-200 | head -24
echo "=== fuxi device pages updated on main"
cd /root/fuxi/up-latest
git log origin/main -6 --date=short --format='%h %ad %s' -- docs/devices/fuxi.md docs/devices/fuxi-mouse233.md docs/devices/fuxi-oddlylabs.md docs/zh/devices/fuxi.md | cut -c1-90
git ls-tree -r --name-only origin/main docs | grep -iE 'usb|fuxi' | grep -v device-records | head
git show origin/main:docs/devices/fuxi-mouse233.md | sed -n 1,16p | cut -c1-260
echo "=== t50 kernel USB"
llvm-nm /root/fuxi/t50/kernel.macho | grep -E '_(qcom_usb_debug_[a-z]+|fuxi_usb[a-z_]*)$' | cut -c18- | head -14
