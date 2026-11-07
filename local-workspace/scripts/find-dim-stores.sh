#!/bin/bash
# Instructions in the t36 kernel that store to +0x16b0 / +0x16b4 (IOMobileFramebufferLegacy boot width/height, "d+5808" in
# the sheng log), with the function they are in and the instructions before them.
K=/root/fuxi/t36/kernel.macho
llvm-objdump -d --no-show-raw-insn $K > /root/fuxi/t36.dis 2>/dev/null
grep -nE 'str(\s+)w[0-9]+, \[x[0-9]+, #0x16b[04]\]|stp(\s+)w[0-9]+, w[0-9]+, \[x[0-9]+, #0x16b0\]' /root/fuxi/t36.dis | head -20
for n in $(grep -nE 'stp(\s+)w[0-9]+, w[0-9]+, \[x[0-9]+, #0x16b0\]|str(\s+)w[0-9]+, \[x[0-9]+, #0x16b0\]' /root/fuxi/t36.dis | cut -d: -f1 | head -6); do
  echo "----- context of line $n"
  # nearest function label above
  awk -v n=$n 'NR<=n && /^[0-9a-f]+ <.*>:$/ {f=$0} NR==n {print f}' /root/fuxi/t36.dis
  sed -n "$((n-14)),$((n+2))p" /root/fuxi/t36.dis
done
