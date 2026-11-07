#!/bin/bash
# Can the current addon switch the export on? Read-only: it reads the image into a scratch directory.
A=/root/fuxi/src-adrenometal; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150
git -C $A show $P:NativeAdrenoMetalPlugin.mm | sed -n 518,536p | cut -c1-210
git -C $A show $P:NativeAdrenoMetalPlugin.mm | grep -n -A12 -m1 'requestedPath(const' | cut -c1-190
cd /mnt/e/DSH-Fuxi/dump/wsl && bash verify-gpu-image.sh /mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img 2>&1 | tail -30 | cut -c1-150
W=/root/fuxi/verify-img
python3 - <<'EOF'
import struct
d=open('/root/fuxi/verify-img/addon.bin','rb').read()
print(len(d), d[:8], [hex(x) for x in struct.unpack_from('<8I',d,8)])
EOF
grep -n -a -E 'NGPUADD2|struct\.|sha256|def ' /mnt/e/DSH-Fuxi/dump/wsl/patch-trustcache.py | cut -c1-130 | head -14
U=/root/fuxi/src-unixnu
git -C $U show origin/main:scripts/make-gpu-addon.py | grep -n -E 'NGPUADD|struct\.|cacheexport|zlib|compress|sha256|fillerx|--cache' | cut -c1-170 | head -24
