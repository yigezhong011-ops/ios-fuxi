#!/bin/bash
# Which boot do the refusals belong to? Find log strings only the new plugin has, and where they fall against the refusals.
N=/mnt/e/DSH-Fuxi/logs/carve-g7plug/lscan.txt; T=/tmp/g7p; mkdir -p $T
python3 -I - /root/fuxi/t50-g7plug/addon-cur.bin /root/fuxi/gpu-plugin-1105/gpuaddon.bin $T <<'EOF'
import struct, sys, zlib
def get(p, want):
    b = open(p, 'rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24
    for _ in range(c):
        nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
        n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
        if n == want: return zlib.decompress(b[at:at + pk])
        at += (pk + 7) // 8 * 8
w = 'addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal'
open(sys.argv[3] + '/old.bin', 'wb').write(get(sys.argv[1], w)); open(sys.argv[3] + '/new.bin', 'wb').write(get(sys.argv[2], w))
EOF
strings -n 12 $T/old.bin | sort -u > $T/old.s; strings -n 12 $T/new.bin | sort -u > $T/new.s
comm -13 $T/old.s $T/new.s > $T/only-new.s; comm -23 $T/old.s $T/new.s > $T/only-old.s
echo "strings only new $(wc -l < $T/only-new.s), only old $(wc -l < $T/only-old.s)"
grep -a -i -E 'native-metal|sample|constant|refus|poster' $T/only-new.s | cut -c1-130 | head -20
TOT=$(wc -l < $N); echo "total lines $TOT"
echo '--- refusal lines'; grep -a -n 'render pipeline refused' $N | cut -c1-170
L=$(grep -a -n 'render pipeline refused' $N | head -1 | cut -d: -f1)
echo '--- native-metal kinds in the capture'
grep -a '^native-metal' $N | sed -E 's/0x[0-9a-f]+/N/g; s/[0-9]+/N/g' | cut -c1-90 | sort | uniq -c | sort -rn | head -25
echo '--- position of native-metal lines, percent of lines'
grep -a -n '^native-metal' $N | cut -d: -f1 | awk -v t=$TOT '{b=int($1*20/t); c[b]++} END{for(i=0;i<20;i++) printf "%d%%:%d ",i*5,c[i]+0; print ""}'
echo '--- new-only strings seen in the capture'
grep -a -E 'native-metal|pipeline|sample' $T/only-new.s | cut -c1-80 | head -40 > $T/pat
if [ -s $T/pat ]; then grep -a -n -F -f $T/pat $N | cut -c1-140 | head -12; fi
echo '--- context before the refusal'
[ -n "$L" ] && sed -n "$((L-8)),$((L+3))p" $N | cut -c1-140
