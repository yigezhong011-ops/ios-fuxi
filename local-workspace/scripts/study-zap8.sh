#!/bin/bash
# Read-only. 1: is any hang boot's log still here? 2: when does COM3 come up relative to the log clock? 3: is the zap region in the kernel's memory?
echo "=== shortest logs anywhere"
for f in $(find /root/fuxi /mnt/e/DSH-Fuxi/logs -name latest.txt 2>/dev/null); do
  t=$(grep -a -m1 -o -E '^#slot [0-9]+ t=[0-9]+s' "$f" | sed -E 's/.*t=([0-9]+)s/\1/')
  [ -n "$t" ] && [ "$t" -lt 40 ] && echo "$t $f $(stat -c %y "$f" | cut -c1-16)"
done | sort -n | head
echo "=== notes on the zap and memory"
for r in /root/fuxi/ref-fuxi-v2 /root/fuxi/src-unixnu /root/fuxi/unixnu-fuxi /root/fuxi/ref-gopfb; do
  [ -d $r ] || continue
  echo "-- $r"
  git -C $r grep -n -I -i -E '9b09a000|gpu_micro_code|kZapPhys|kZapBytes|no-map|nomap|reserved.?mem' HEAD 2>/dev/null | cut -c1-165 | head -16
done
ls /mnt/e/DSH-Fuxi/unixnu-build 2>/dev/null | head; ls /mnt/e/DSH-Fuxi/unixnu-build/fuxi 2>/dev/null | head -30
echo "=== physmap in t50"
K=/root/fuxi/t50/kernel.macho
llvm-nm $K | grep -E 'arm_vm_physmap|_gPhysBase|_gPhysSize|_mem_size$|_real_avail_end|_avail_start$|_avail_end$|_physmap_base|_physmap_end' | cut -c1-80
