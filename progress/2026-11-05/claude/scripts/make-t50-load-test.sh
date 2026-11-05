#!/bin/bash
# Per-CPU busy time and raw EPSS state, on the image that proved good: only the blob differs. Temp boot only.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
llvm-nm /root/fuxi/t50/kernel.macho | grep -E ' _(processor_array|processor_info|ml_io_map)$'
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh; tr -d '\r' < $S/make-t50-privlog.sh > /tmp/pl.sh
grep -n 'ML_IO_MAP' $S/fuxi-buttons-blob.c | head -3 | cut -c1-120
bash /tmp/g120.sh t50-mine-gpu-load -DPANEL_120 -DCPU_LOAD -DCLOCK_SECS=$(date +%s)UL
bash /tmp/pl.sh /root/fuxi/t50-mine-gpu-load /root/fuxi/t50-priv-load
bash /tmp/a.sh /root/fuxi/t50-priv-load 300 t50-auto-load
llvm-objdump -d /root/fuxi/t50-mine-gpu-load/kernel.blob.elf | grep -n 'bl\b\|blr' | wc -l