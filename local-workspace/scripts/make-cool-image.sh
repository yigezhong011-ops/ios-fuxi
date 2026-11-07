#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
SRC=$P/boot-gpu3-cpus6.img
OUT=$P/boot-gpu3-cool.img
python3 - "$SRC" "$OUT" <<'PY'
import sys, pathlib
src, out = sys.argv[1], sys.argv[2]
img = bytearray(pathlib.Path(src).read_bytes())
i = img.find(b'SWEETXNU')
assert i >= 0, 'payload not found'
base = i + 0x48
cmd = bytes(img[base:base + 608]).split(b'\0')[0]
print('原:', cmd[-90:].decode(errors='replace'))
new = cmd.replace(b'sweetfb_hz=60', b'sweetfb_hz=30')
assert new != cmd, 'sweetfb_hz=60 not present'
img[base:base + len(new)] = new
img[base + len(new)] = 0
pathlib.Path(out).write_bytes(bytes(img))
print('新:', bytes(img[base:base + 608]).split(b'\0')[0][-90:].decode(errors='replace'))
PY
ls -lh "$OUT"
echo "=== 校验 ==="
strings -a "$OUT" | grep -m1 -o 'sweetfb_hz=[0-9]*'
