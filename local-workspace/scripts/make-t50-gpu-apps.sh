#!/bin/bash
# t50-mine-gpu-fix plus sheng-staged-apps=1: the kernel copies the staged system apps into Data once, before launchd. Only the toml changes.
# Temporary boot only; the first boot writes about 445 MiB into Data.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; W=/root/fuxi/t50-gpu-apps
rm -rf "$W"; mkdir -p "$W"
cp /root/fuxi/gpu-new-t50-mine/vol.img "$W/vol.img"
mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | sha256sum | cut -c1-16
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 - "$W/toml.orig" "$W/toml" <<'EOF'
import re, sys
t = open(sys.argv[1], encoding='utf-8', newline='').read()
m = re.search(r'args = "([^"]*)"', t)
a = m.group(1)
assert 'sheng-staged-apps' not in a
new = a + ' sheng-staged-apps=1'
print('args length', len(a), '->', len(new))
assert len(new) < 1000, 'documented command line limit'
out = t.replace(a, new)
print('toml bytes', len(t), '->', len(out))
open(sys.argv[2], 'w', encoding='utf-8', newline='').write(out)
EOF
python3 -I $E/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml" --grow
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml | cmp - "$W/toml"
python3 -I $E/dump/wsl/repack-with-vol.py $E/t50-mine.img "$W/vol.img" $E/t50-mine-gpu-apps.img
python3 -I $E/dump/wsl/compare-loaders.py $E/t50-mine-gpu-apps.img
python3 - $E/t50-mine-gpu-fix.img $E/t50-mine-gpu-apps.img <<'EOF'
import sys,zlib,struct
def body(p):
    d=open(p,'rb').read(); ks=struct.unpack_from('<I',d,8)[0]; hs=struct.unpack_from('<I',d,20)[0]; st=(hs+4095)//4096*4096
    return len(d), zlib.decompressobj(16+zlib.MAX_WBITS).decompress(d[st:st+ks])
a,x=body(sys.argv[1]); b,y=body(sys.argv[2])
n=[i for i in range(0,min(len(x),len(y)),4096) if x[i:i+4096]!=y[i:i+4096]]
print('image bytes',a,b,'inner',len(x),len(y),'differing 4K pages',len(n),[hex(i) for i in n[:8]])
EOF
sha256sum $E/t50-mine-gpu-apps.img | cut -c1-16
