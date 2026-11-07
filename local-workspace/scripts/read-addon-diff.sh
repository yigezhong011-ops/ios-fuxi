#!/bin/bash
# Compare the addon inside t50-auto-gpu7tap's volume with the 11-05 plugin build. Read-only.
export MTOOLS_SKIP_CHECK=1
V=/root/fuxi/tap-t50-auto-gpu7tap/vol.img; P=/root/fuxi/gpu-plugin-1105; T=/tmp/addon-diff; mkdir -p $T
mtype -i $V ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon > $T/cur.bin
mtype -i $V ::/EFI/UniXNU/Payloads/kernel.macho.trustcache > $T/cur.trust
ls -l $T/cur.bin $P/addon-fitted.bin $P/gpuaddon.bin | cut -c24-
cmp $T/cur.trust $P/trust-orig.bin && echo 'trust: same as plugin base'; cmp $T/cur.trust $P/trust-new.bin >/dev/null && echo 'trust: already plugin'
cat $P/cdhashes.txt | cut -c1-70
python3 -I - $T/cur.bin $P/gpuaddon.bin <<'EOF'
import struct, sys, zlib, hashlib
def rd(p):
    b = open(p, 'rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24; r = {}
    for _ in range(c):
        nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
        n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
        r[n] = (m, s, hashlib.sha256(zlib.decompress(b[at:at + pk])).hexdigest()[:10]); at += (pk + 7) // 8 * 8
    return r
a, o = rd(sys.argv[1]), rd(sys.argv[2])
print('entries cur', len(a), 'plugin', len(o))
for n in sorted(set(a) | set(o)):
    if a.get(n) != o.get(n): print(' ', n, a.get(n), '->', o.get(n))
EOF
mtype -i $V ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | wc -c
echo '--- how the auto image is packed'
sed -n 1,40p /mnt/e/DSH-Fuxi/dump/wsl/make-t50-auto.sh | cut -c1-140
df -h /mnt/e | tail -1
