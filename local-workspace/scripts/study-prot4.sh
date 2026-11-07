#!/bin/bash
# Read-only: the two branch heads, to patch the protection-class reads exactly.
K=/root/fuxi/t50/kernel.macho
echo '--- fcntl success path'; llvm-objdump -d --start-address=0xfffffff00bd22b04 --stop-address=0xfffffff00bd22b24 $K 2>/dev/null | tail -n +7 | cut -c1-100
echo '--- fcntl head of the read case'; llvm-objdump -d --start-address=0xfffffff00bd225a0 --stop-address=0xfffffff00bd225e0 $K 2>/dev/null | tail -n +7 | cut -c1-100
echo '--- attr_pack_common, callers of the block'
llvm-objdump -d --start-address=0xfffffff00ba9e8bc --stop-address=0xfffffff00baa00a8 $K 2>/dev/null > /tmp/apc.txt
grep -n -E '0xfffffff00ba9fc08|0xfffffff00ba9fbe|0xfffffff00ba9fbd|0xfffffff00ba9fbc' /tmp/apc.txt | cut -c1-100
L=$(grep -n '^fffffff00ba9fbf0' /tmp/apc.txt | cut -d: -f1); sed -n "$((L-22)),$((L+1))p" /tmp/apc.txt | cut -c1-100
