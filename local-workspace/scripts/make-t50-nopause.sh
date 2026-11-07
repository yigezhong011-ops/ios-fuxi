#!/bin/bash
# Build t50-nopause.img: the daily volume (new plugin) with sheng-gpu-pause-us removed.
# Same loader and DTB as t50-mine-gpu-fix.img; only the boot args change.
set -euo pipefail
BASE=/mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img
OUT=t50-nopause
W=/root/fuxi/nopause
rm -rf "$W"; mkdir -p "$W"

python3 - "$BASE" "$W/vol.img" <<'PY'
import struct, sys, zlib
from pathlib import Path
img, out = Path(sys.argv[1]), Path(sys.argv[2])
d = img.read_bytes()
hs = struct.unpack_from('<I', d, 20)[0]
ks = struct.unpack_from('<I', d, 8)[0]
start = (hs + 4095) // 4096 * 4096
un = zlib.decompressobj(16 + zlib.MAX_WBITS)
body = un.decompress(d[start:start + ks])
fat = next(m for m in range(0, 8 << 20, 2)
           if len(body[m:m+512]) == 512 and body[m+0x52:m+0x5a].startswith(b'FAT32')
           and body[m+0x1fe:m+0x200] == b'\x55\xaa')
total = struct.unpack_from('<I', body, fat + 32)[0]
out.write_bytes(body[fat:fat + total * 512])
print('卷 %d 字节' % (total * 512))
PY

export MTOOLS_SKIP_CHECK=1
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 - "$W/toml.orig" "$W/toml" <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read(); t = old.decode()
m = re.search(r'args = "([^"]*)"', t)
args = [a for a in m.group(1).split() if not a.startswith('sheng-gpu-pause-us')]
new_args = ' '.join(args)
removed = set(m.group(1).split()) - set(args)
print('去掉:', removed, '参数数', len(args))
new = (t[:m.start()] + 'args = "' + new_args + '"' + t[m.end():]).encode()
assert len(new) <= len(old), len(new) - len(old)
new = new.rstrip(b'\n') + b'\n' + b' ' * (len(old) - len(new.rstrip(b'\n')) - 1)
open(sys.argv[2], 'wb').write(new)
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py "$BASE" "$W/vol.img" "/mnt/e/DSH-Fuxi/$OUT.img"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/compare-loaders.py "/mnt/e/DSH-Fuxi/$OUT.img"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml | grep -o 'sheng-gpu-[a-z-]*=[^ "]*' | sort -u | head -8
