#!/bin/bash
# Read only: finds the blob's poller loop in the g7cpu kernel, the "mov w0,#20; bl IOSleep" a one-word hook can take.
K=/root/fuxi/tap-t50-auto-g7cpu/kernel.macho
T=0xfffffff00c0902c0; SLEEP=fffffff00bf0c2cc
END=$(python3 -I -c "print(hex($T + 0x2800))")
llvm-objdump -d --no-show-raw-insn --start-address=$T --stop-address=$END $K > /tmp/blob-dis.txt
wc -l < /tmp/blob-dis.txt
echo '== every call of IOSleep, with the three words before it'
grep -n -B3 -E "bl\s+0x$SLEEP" /tmp/blob-dis.txt | sed -E 's/<[^>]*>//' | cut -c1-72
echo '== words after the #0x14 sleeps'
grep -n -A6 -E 'mov\s+w0, #0x14' /tmp/blob-dis.txt | sed -E 's/<[^>]*>//' | cut -c1-72 | head -40
