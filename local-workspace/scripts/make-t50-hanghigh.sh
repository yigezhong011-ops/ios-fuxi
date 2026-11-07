#!/bin/bash
# t50-auto-hanglog with its slots written from slot 500, so the daily boot a hang falls into does not overwrite them. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
export LOG_FAST=1 LOG_HIGH=1
bash /tmp/g120.sh t50-mine-gpu-hanghigh -DPANEL_120 -DCLOCK_SECS=$(date +%s)UL
unset LOG_FAST LOG_HIGH
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-hanghigh /root/fuxi/t50-priv-hanghigh
bash /tmp/a.sh /root/fuxi/t50-priv-hanghigh 60 t50-auto-hanghigh
A=$(llvm-nm /root/fuxi/t50/kernel.macho | awk '$3=="_writer"{print $1}')
echo "=== writer sleep and slot base"
llvm-objdump -d --start-address=$(printf '0x%x' $((0x$A + 0x298))) --stop-address=$(printf '0x%x' $((0x$A + 0x2a0))) /root/fuxi/t50-mine-gpu-hanghigh/kernel.macho | tail -n 2 | cut -c19-70
llvm-objdump -d --start-address=$(printf '0x%x' $((0x$A + 0x2e8))) --stop-address=$(printf '0x%x' $((0x$A + 0x2f8))) /root/fuxi/t50-mine-gpu-hanghigh/kernel.macho | tail -n 4 | cut -c19-70
echo "=== diff against hanglog's kernel"
cmp -l /root/fuxi/t50-mine-gpu-hanglog/kernel.macho /root/fuxi/t50-mine-gpu-hanghigh/kernel.macho | wc -l
sha256sum /mnt/e/DSH-Fuxi/t50-auto-hanghigh.img | cut -c1-16
ls -la /mnt/e/DSH-Fuxi/t50-auto-hanghigh.img
