#!/bin/bash
# Read-only: the protection-class branch in attr_pack_common and the F_GETPROTECTIONCLASS case in fcntl; who in the shared cache names the conform check.
K=/root/fuxi/t50/kernel.macho
llvm-objdump -d --start-address=0xfffffff00ba9e8bc --stop-address=0xfffffff00ba9f400 $K 2>/dev/null > /tmp/apc.txt
wc -l /tmp/apc.txt
grep -n -E 'tb(n)?z.*#0x1e\b|tb(n)?z.*#30\b' /tmp/apc.txt | cut -c1-100
L=$(grep -n -E 'tbz.*#0x1e|tbnz.*#0x1e' /tmp/apc.txt | tail -1 | cut -d: -f1)
[ -n "$L" ] && sed -n "$((L-3)),$((L+26))p" /tmp/apc.txt | cut -c1-100
echo '=== fcntl vnode_getattr calls with the class word'
llvm-objdump -d --start-address=0xfffffff00bd20cd4 --stop-address=0xfffffff00bd22d00 $K 2>/dev/null > /tmp/fc.txt
grep -n 'VNOP_SETATTR\|vnode_getattr' /tmp/fc.txt | cut -c1-100 | head -20
grep -n -E '#0x40000000000|, #0x3f$|#0x3f\b|#0x40$|#63\b|#64\b' /tmp/fc.txt | cut -c1-90 | head -12
echo '=== shared cache'
cd /root/fuxi/sys-peek/dsc
for p in PFPosterPathURLResourceValues pbf_URLIsReachableAndConform URLIsReachableAndConform ConformToResourceValues; do
  printf '%-34s' "$p"; for f in dyld_shared_cache_arm64*; do LC_ALL=C grep -a -c -F "$p" "$f" 2>/dev/null | awk -v f="$f" '$1>0{printf " %s:%s", f, $1}'; done; echo
done
