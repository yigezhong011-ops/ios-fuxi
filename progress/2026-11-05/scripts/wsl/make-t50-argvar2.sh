#!/bin/bash
# Build a variant of the daily image with boot arguments added/removed.
# Usage: make-t50-argvar2.sh <out-name> <add:arg=value|rm:key> [more...]
# The toml keeps its file size (the Data seed lives in the FAT's free clusters); when the
# arguments grow, the cosmetic boot title shrinks to make room.
set -euo pipefail
OUT=${1:?输出名}
shift
ACTIONS=("$@")
[ ${#ACTIONS[@]} -gt 0 ] || { echo "至少给一个动作"; exit 1; }
BASE=/mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img
W=/root/fuxi/var-$OUT
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
PY

export MTOOLS_SKIP_CHECK=1
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 - "$W/toml.orig" "$W/toml" "${ACTIONS[@]}" <<'PY'
import re, sys
old = open(sys.argv[1], 'rb').read()
t = old.decode()
actions = sys.argv[3:]
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()
for action in actions:
    if action.startswith('add:'):
        arg = action[4:]
        key = arg.split('=')[0]
        args = [a for a in args if a.split('=')[0] != key] + [arg]
        print('  加入', arg)
    elif action.startswith('rm:'):
        key = action[3:]
        n = len(args)
        args = [a for a in args if a.split('=')[0] != key]
        print('  移除', key, '（%d 个）' % (n - len(args)))
    else:
        sys.exit('动作必须是 add: 或 rm:')
body = t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]
new = body.encode()
if len(new) > len(old):
    shortened = body.replace('title = "fuxi first boot: source 4K XNU to console"', 'title = "fuxi"')
    shortened = shortened.replace('title = "Restart"', 'title = "R"')
    shortened = shortened.replace('title = "Power off"', 'title = "P"')
    if len(shortened.encode()) <= len(old):
        body = shortened
        new = body.encode()
if len(new) > len(old):
    sys.exit('参数太长，放不下（差 %d 字节）' % (len(new) - len(old)))
new = new + b' ' * (len(old) - len(new))
assert len(new) == len(old)
open(sys.argv[2], 'wb').write(new)
print('  参数 %d 个 / %d 字符' % (len(args), len(' '.join(args))))
PY

python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml"
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py "$BASE" "$W/vol.img" "/mnt/e/DSH-Fuxi/$OUT.img"
echo "--- 校验参数 ---"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml | tr ' ' '\n' | grep -E 'sheng-gpu-(mailbox|wc|coherent)|boot-ui-focus' | head -6
