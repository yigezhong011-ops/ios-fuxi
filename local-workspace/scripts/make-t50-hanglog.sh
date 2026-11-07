#!/bin/bash
# t50-auto-120clock-p's options, with the boot log written every 250 ms and a 60 s return to fastboot: boot it until a Mi-logo hang, then read the last slot. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
export LOG_FAST=1
bash /tmp/g120.sh t50-mine-gpu-hanglog -DPANEL_120 -DCLOCK_SECS=$(date +%s)UL
unset LOG_FAST
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-hanglog /root/fuxi/t50-priv-hanglog
bash /tmp/a.sh /root/fuxi/t50-priv-hanglog 60 t50-auto-hanglog
A=$(llvm-nm /root/fuxi/t50/kernel.macho | awk '$3=="_writer"{print $1}')
llvm-objdump -d --start-address=$(printf '0x%x' $((0x$A + 0x298))) --stop-address=$(printf '0x%x' $((0x$A + 0x2a0))) /root/fuxi/t50-mine-gpu-hanglog/kernel.macho | tail -n 2 | cut -c19-70
sha256sum /mnt/e/DSH-Fuxi/t50-auto-hanglog.img | cut -c1-16
