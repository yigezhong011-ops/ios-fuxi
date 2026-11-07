#!/bin/bash
# t50-auto-load, plus the blob asking the scheduler to stay off the A510s (cpu0-2): recommended cores 0xf8. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
bash /tmp/g120.sh t50-mine-gpu-big -DPANEL_120 -DCPU_LOAD -DCPU_BIG=0xf8 -DCLOCK_SECS=$(date +%s)UL
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-big /root/fuxi/t50-priv-big
bash /tmp/a.sh /root/fuxi/t50-priv-big 300 t50-auto-big
llvm-objdump -d /root/fuxi/t50-mine-gpu-big/kernel.blob.elf | grep -n -E 'b8e3810|recommended' | head -5 || true
