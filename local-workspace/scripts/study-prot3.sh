#!/bin/bash
# Read-only: fcntl's getattr sites, and the data-protect branch in attr_pack_common.
K=/root/fuxi/t50/kernel.macho
llvm-objdump -d --start-address=0xfffffff00bd20cd4 --stop-address=0xfffffff00bd22d00 $K 2>/dev/null > /tmp/fc.txt
grep -n 'VNOP_GETATTR\|vnode_getattr' /tmp/fc.txt | cut -c1-100 | head
L=$(grep -n 'VNOP_SETATTR' /tmp/fc.txt | cut -d: -f1); sed -n "$((L-44)),$((L+6))p" /tmp/fc.txt | cut -c1-96
for s in $(grep -n 'VNOP_GETATTR' /tmp/fc.txt | cut -d: -f1 | head -4); do echo "--- site line $s"; sed -n "$((s-12)),$((s+14))p" /tmp/fc.txt | cut -c1-96; done
llvm-objdump -d --start-address=0xfffffff00ba9fbf0 --stop-address=0xfffffff00ba9fc80 $K 2>/dev/null | tail -n +7 | cut -c1-100
