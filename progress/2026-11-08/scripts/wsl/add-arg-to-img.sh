#!/bin/bash
# Add one boot argument to an existing image and write a new image with the same loader and DTB.
# Usage: add-arg-to-img.sh <in.img> <arg=value> <out-name>
set -euo pipefail
IN=${1:?输入镜像}
ARG=${2:?参数}
OUT=${3:?输出名}
E=/mnt/e/DSH-Fuxi
W=/root/fuxi/arg-$OUT
rm -rf "$W"; mkdir -p "$W"

python3 - "$IN" "$W/vol.img" <<'PY'
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
PY

export MTOOLS_SKIP_CHECK=1
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 - "$W/toml.orig" "$W/toml" "$ARG" <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read()
t = old.decode()
arg = sys.argv[3]
key = arg.split('=')[0]
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()
before = len(' '.join(args))
args = [a for a in args if a.split('=')[0] != key] + [arg]
line = ' '.join(args)
print('  参数 %d 个 / %d 字符（原 %d）' % (len(args), len(line), before))
assert len(line) < 1020, 'too long'
body = t[:m.start()] + 'args = "' + line + '"' + t[m.end():]
new = body.encode()
if len(new) > len(old):
    body = body.replace('title = "fuxi first boot: source 4K XNU to console"', 'title = "fuxi"')
    body = body.replace('title = "Restart"', 'title = "R"').replace('title = "Power off"', 'title = "P"')
    body = body.replace('title = "Tools"', 'title = "T"')
    body = body.replace('title = "fuxi"', 'title = "f"')
    new = body.encode()
assert len(new) <= len(old), 'no room: %d > %d' % (len(new), len(old))
new = new + b' ' * (len(old) - len(new))
open(sys.argv[2], 'wb').write(new)
PY

python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml" >/dev/null
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py "$IN" "$W/vol.img" "$E/$OUT.img"
echo "--- 校验参数 ---"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml | tr ' ' '\n' | grep -E "sheng-metal-flow|sheng-autoreset" | head -3
