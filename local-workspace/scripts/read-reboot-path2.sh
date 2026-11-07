#!/bin/bash
# Read-only: the REBOOT worker, boot_reset_bootloader and what follows the panic drain in the t50 kernel; the blob's size budget.
set -u
K=/root/fuxi/t50/kernel.macho; A=/root/fuxi/t50.dis
[ -s "$A" ] || llvm-objdump -d --no-show-raw-insn "$K" > "$A" 2>/dev/null
wc -l "$A"
r() { awk -v a="$1" -v b="$2" '{k=substr($1,1,16)} k>=a && k<=b' "$A" | cut -c1-105; }
echo '== reboot worker'; r fffffff00bd0d8f4 fffffff00bd0d9c0
echo '== caller of the worker take (bd0d82c region)'; r fffffff00bd0d810 fffffff00bd0d850
echo '== boot_reset_bootloader'; grep -n -E '_boot_reset[a-z_]*>:' "$A"
awk 'index($0,"<_boot_reset_bootloader>:"){p=1} p{print; c++} c>60{exit}' "$A" | cut -c1-105
echo '== after panic drain'; r fffffff00b8a3200 fffffff00b8a3290
echo '== callers of boot_reset_bootloader'; grep -n -E 'bl\s.*_boot_reset_bootloader>' "$A" | cut -c1-100
