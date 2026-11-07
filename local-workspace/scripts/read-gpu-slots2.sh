#!/bin/bash
# Read-only: kClientWindows contents and users in t50, the mount code around the slot loop, queue limits.
set -u
K=/root/fuxi/t50/kernel.macho; A=/root/fuxi/t50.dis; N=/tmp/t50-syms.txt
ls -la "$K" "$A" | cut -c24-
[ -s "$N" ] || llvm-nm --defined-only "$K" > "$N" 2>/dev/null
python3 -I - "$K" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
n = struct.unpack_from('<I', d, 16)[0]; at = 32
want = 0xfffffff0070450b0
for i in range(n):
    c, s = struct.unpack_from('<II', d, at)
    if c == 0x19:
        name = d[at+8:at+24].rstrip(b'\0').decode(); va, vs, fo, fs = struct.unpack_from('<QQQQ', d, at+24)
        if va <= want < va + vs:
            print('segment', name, hex(va), hex(fo))
            o = want - va + fo
            for k in range(6):
                print(hex(want + k*16), [hex(x) for x in struct.unpack_from('<QQ', d, o + k*16)])
    at += s
PY
echo '== xrefs to kClientWindows'
grep -n -E 'adrp.*0xfffffff007045000' "$A" | cut -c1-90 | head -12
L=$(grep -n -E 'adrp.*0xfffffff007045000' "$A" | head -40 | cut -d: -f1)
for l in $L; do sed -n "$l,$((l+2))p" "$A" | grep -q '0xb0\|#176' && echo "hit line $l"; done | head -10
echo '== methods holding slot code'
grep -E 'AGXDevice|GpuClient.*mount|mount' "$N" | grep -i -E 'adreno|agx' | cut -c1-120 | head -16
grep -n -E '__ZN21NativeAdrenoGpuClient12initWithTask|__ZN21NativeAdrenoGpuClient11clientClose|__ZN21NativeAdrenoGpuClient14externalMethod' "$A" | cut -c1-90 | head
tail -3 /root/fuxi/fw/build-base.log 2>/dev/null | cut -c1-140
echo '== logged client rows and refusal lines in saved logs'
cd /mnt/e/DSH-Fuxi/logs 2>/dev/null && grep -l -E 'gpu clients|re00002d5' * 2>/dev/null | tail -4
f=$(grep -l -E 're00002d5' * 2>/dev/null | tail -1); [ -n "$f" ] && { echo "file $f"; grep -a -E 're00002d5|gpu client|gpu windows|gpu mount|VkResult|device refused' "$f" | cut -c1-200 | tail -30; }
