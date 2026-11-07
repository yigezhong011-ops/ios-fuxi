#!/bin/bash
# Temp boot test: which cores does PSCI report on? 120 Hz blob with CPU_PROBE, autoreset, and no logging overlay.
set -euo pipefail
S=/mnt/e/DSH-Fuxi/dump/wsl
tr -d '\r' < $S/make-t50-gpu-120.sh > /tmp/g120.sh; tr -d '\r' < $S/make-t50-auto.sh > /tmp/a.sh
sed -n 1,2p $S/patch-t32-buttons.py >/dev/null
nm -a /root/fuxi/t50/kernel.macho 2>/dev/null | grep -E ' _real_ncpus$' || llvm-nm /root/fuxi/t50/kernel.macho | grep -E ' _real_ncpus$'
bash /tmp/g120.sh t50-mine-gpu-cpu -DPANEL_120 -DCPU_PROBE
bash /tmp/a.sh /root/fuxi/t50-mine-gpu-cpu 200 t50-auto-cpu
llvm-objdump -d /root/fuxi/t50-mine-gpu-cpu/kernel.blob.elf 2>/dev/null | grep -c 'smc' || true