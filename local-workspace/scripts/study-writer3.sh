#!/bin/bash
# Read-only: slot address computation in _writer, the slot count, and the write's bounds check.
K=/root/fuxi/t50/kernel.macho
llvm-objdump -d --start-address=0xfffffff00c029680 --stop-address=0xfffffff00c029c50 $K | tail -n +7 > /tmp/w.txt
echo "== header setup (slot_first / count)"; grep -n -E 'mov\s+x8, #0x21' /tmp/w.txt | cut -c1-90
L=$(grep -n -E 'mov\s+x8, #0x21' /tmp/w.txt | head -1 | cut -d: -f1); sed -n "$((L-22)),$((L+10))p" /tmp/w.txt | cut -c1-90
echo "== slot write"; L=$(grep -n -E 'add\s+x0, x8, #0x21' /tmp/w.txt | head -1 | cut -d: -f1); sed -n "$((L-14)),$((L+6))p" /tmp/w.txt | cut -c1-90
echo "== all uses of w26"; grep -n -E '\b(w26|x26)\b' /tmp/w.txt | cut -c1-90 | head -16
echo "== native_ufs_log_write"; llvm-objdump -d --start-address=0xfffffff00bff4e4c --stop-address=0xfffffff00bff4f08 $K | tail -n +7 | cut -c1-90 | head -50
echo "== source"; F=/root/fuxi/ref-fuxi-v2/drivers/NativeUfs/NativeUfs.cpp; L=$(grep -n 'native_ufs_log_write' $F | head -1 | cut -d: -f1); sed -n "$L,$((L+16))p" $F | cut -c1-120
sed -n 668,684p /root/fuxi/ref-fuxi-v2/package/BootLog.c | cut -c1-170
grep -n -E 'LogSlotFirst|LogSlotBlocks|LogMsgBlocks|LogPeriodMs' /root/fuxi/ref-fuxi-v2/package/BootLog.c | head -8 | cut -c1-110
