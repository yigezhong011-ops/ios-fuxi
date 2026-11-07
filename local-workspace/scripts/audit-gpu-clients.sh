#!/bin/bash
# The old addon carries .clients and .primelist entries that the CI addon lacks: what are they, who reads them. Read-only.
export MTOOLS_SKIP_CHECK=1
mkdir -p /tmp/ga; cd /tmp/ga
python3 - <<'EOF'
import struct, subprocess, zlib
from pathlib import Path
def parse(blob):
    count = struct.unpack_from('<I', blob, 8)[0]
    off, res = 24, {}
    for _ in range(count):
        nlen, mode, size, csize = struct.unpack_from('<IIQQ', blob, off); off += 24
        name = blob[off:off+nlen-1].decode(); off += nlen + (-nlen % 8)
        res[name] = zlib.decompress(blob[off:off+csize]); off += csize + (-csize % 8)
    return res
for tag, vol in (('old', '/root/fuxi/t50-mine/vol.img'), ('new', '/root/fuxi/gpu-new-t50-mine/vol.img')):
    b = subprocess.run(['mtype','-i',vol,'::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'],capture_output=True).stdout
    for n, d in parse(b).items():
        p = Path(tag) / n; p.parent.mkdir(parents=True, exist_ok=True); p.write_bytes(d)
EOF
echo "== old clients"; cat old/addons/NativeAdrenoMetal.clients; echo
echo "== old primelist head"; head -c 600 old/addons/NativeAdrenoMetal.primelist; echo; wc -l old/addons/NativeAdrenoMetal.primelist
echo "== publish old/new"; xxd old/addons/NativeAdrenoMetal.publish; xxd new/addons/NativeAdrenoMetal.publish
for k in /root/fuxi/t50-mine/kernel.macho /root/fuxi/t36-bl2/kernel.macho; do
  echo "== strings in $k"; strings -a $k | grep -E 'NativeAdrenoMetal\.|\.clients|primelist|gpu-clients|sheng-gpu-(clients|prime)' | cut -c1-160 | sort -u | head -30
done
for t in old new; do
  echo "== $t plugin strings"; strings -a $t/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal | grep -E 'primelist|\.clients|\.publish' | cut -c1-160 | sort -u | head
done
echo "== local sources"
ls /mnt/e/DSH-Fuxi/dump/wsl | grep -i -E 'addon|client|prime'
grep -rl -E 'NativeAdrenoMetal\.clients|primelist' /root/fuxi/unixnu-build --include='*' 2>/dev/null | grep -v -E '/out/|\.git/|\.macho|\.bin$' | head -20
echo "== plugin section sizes old vs new"
for t in old new; do python3 - $t/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal <<'EOF'
import struct,sys
d=open(sys.argv[1],'rb').read()
n=struct.unpack_from('<I',d,16)[0];o=32
for _ in range(n):
    c,s=struct.unpack_from('<II',d,o)
    if c==0x19:
        name=d[o+8:o+24].rstrip(b'\0').decode(); fs=struct.unpack_from('<Q',d,o+48)[0]; print(' ',name,fs)
    o+=s
EOF
done
