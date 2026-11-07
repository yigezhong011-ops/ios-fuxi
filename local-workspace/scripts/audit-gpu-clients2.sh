#!/bin/bash
# What replaced .clients upstream, what happens with no primelist, and whether the kernel ABI still fits. Read-only.
cd /root/fuxi/src-adrenometal
PIN=7e0d3d2ebaecd736784de0baa09254b7f63bc150
echo "== 3b4acf1 message and the clients lines it removed"
git log -1 --format='%B' 3b4acf1 | head -30 | cut -c1-200
git show 3b4acf1 --format= -G'clients' --stat | tail -15 | cut -c1-100
git show 3b4acf1 --format= | grep -n -E '^[-+].*(\.clients|clients|listed process|kClient)' | head -40 | cut -c1-170
echo "== at pin: client / per-process device logic"
git grep -n -i -E 'own Metal device|listed process|render server|isRenderServer|backboardd|client slot|MAX_CLIENT|kMaxClient' $PIN -- 'plugin' 'src' '*.m' '*.mm' '*.h' '*.c' 2>/dev/null | sed "s/^$PIN://" | head -40 | cut -c1-190
echo "== at pin: prime list"
git grep -n -E 'primelist|prime-list|PrimeList|__primelist' $PIN | sed "s/^$PIN://" | head -30 | cut -c1-190
F=$(git grep -l 'NativeAdrenoMetal.primelist' $PIN | head -1 | sed "s/^$PIN://"); echo "file: $F"
[ -n "$F" ] && git show $PIN:"$F" | grep -n -B8 -A25 'NativeAdrenoMetal.primelist' | head -90 | cut -c1-170
echo "== ABI header history"
git log --format='%h %cI %s' -8 -- '*NativeAdrenoABI*' | cut -c1-100
git ls-tree -r --name-only $PIN | grep -i -E 'abi' | head
cd /tmp/ga
python3 - <<'EOF'
import struct
for t in ('old', 'new'):
    d = open(f'/tmp/ga/{t}/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal', 'rb').read()
    n = struct.unpack_from('<I', d, 16)[0]; o = 32
    for _ in range(n):
        c, s = struct.unpack_from('<II', d, o)
        if c == 0x19:
            for i in range(struct.unpack_from('<I', d, o + 64)[0]):
                a = o + 72 + i * 80
                sn = d[a:a + 16].rstrip(b'\0')
                if sn in (b'__primelist',):
                    size = struct.unpack_from('<Q', d, a + 40)[0]; off = struct.unpack_from('<I', d, a + 48)[0]
                    print(t, sn, 'size', size, repr(d[off:off + 100]))
        o += s
EOF
