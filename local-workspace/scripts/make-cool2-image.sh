#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
SRC=$P/boot-gpu3-cpus6.img
OUT=$P/boot-gpu3-cool2.img
python3 - "$SRC" "$OUT" <<'PY'
import sys, pathlib
src, out = sys.argv[1], sys.argv[2]
img = bytearray(pathlib.Path(src).read_bytes())
i = img.find(b'SWEETXNU')
assert i >= 0
base = i + 0x48
raw = bytes(img[base:base + 608])
cmd = raw.split(b'\0')[0]
print('原:', cmd.decode(errors='replace')[-200:])

new = cmd.replace(b'sweetfb_hz=60', b'sweetfb_hz=30')
# 把 execswap 参数整体替换为等长空格，保持 cmdline 长度不变
needle = b'sweetexecswap=peakpowermanagerd:/usr/local/bin/fuxi-metal-smoke'
if needle in new:
    new = new.replace(needle, b' ' * len(needle))
# 折叠多余空格不影响解析：内核按空白切分
img[base:base + 608] = b'\0' * 608
img[base:base + len(new)] = new
pathlib.Path(out).write_bytes(bytes(img))
print('新:', new.decode(errors='replace')[-200:])
PY
ls -lh "$OUT"
strings -a "$OUT" | grep -m1 -o 'sweetfb_hz=[0-9]*'
strings -a "$OUT" | grep -c 'sweetexecswap' || true
