#!/bin/bash
# Read-only: the boot log writer's sleep in t50, to shorten the log period in a diagnostic image.
K=/root/fuxi/t50/kernel.macho
llvm-nm $K | grep -E 'GLOBAL__N_1.*writer|[^a-z]_?writer$|_boot_log_tick|_IOSleep$' | cut -c1-90
A=$(llvm-nm $K | awk '$3=="_writer"{print $1}')
[ -z "$A" ] && { echo no writer; exit 0; }
llvm-objdump -d --start-address=0x$A --stop-address=$(printf '0x%x' $((0x$A + 0x900))) $K 2>/dev/null | grep -n -E -B3 '_IOSleep|bl .*IOSleep' | cut -c1-90 | head -30
echo "=== rows by second in the good boot"
grep -a -E '^#slot|^X6 |^X5 ' /root/fuxi/cad-ab/untagged-6798de11ea/slots.txt | sed -n 1,48p | cut -c1-70
