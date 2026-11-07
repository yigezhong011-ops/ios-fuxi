#!/bin/bash
set -euo pipefail
IMG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/boot-gpu3-v4.img
OUT=/root/fuxi/fw-correct
mkdir -p "$OUT"
python3 - "$IMG" "$OUT" <<'PY'
import sys, hashlib, pathlib
img = pathlib.Path(sys.argv[1]).read_bytes()
out = pathlib.Path(sys.argv[2])
gmu = img[118984:118984 + 66844]
sqe = img[185828:185828 + 75380]
zap = img[261208:261208 + 12088]
for name, blob in (('gmu_gen70200.bin', gmu), ('a740_sqe.fw', sqe), ('a740_zap.mbn', zap)):
    (out / name).write_bytes(blob)
    print('%-20s %6d  %s' % (name, len(blob), hashlib.sha256(blob).hexdigest()[:16]))
PY
ls -l "$OUT"

echo "=== 修补 payload 的 cmdline 为 cpus=6 ==="
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
cp "$P/payload.bin" /root/fuxi/payload-pkg.bin
python3 - <<'PY'
import pathlib
p = pathlib.Path('/root/fuxi/payload-pkg.bin')
b = bytearray(p.read_bytes())
assert b[:8] == b'SWEETXNU', b[:8]
base = 0x48
cmd = bytes(b[base:base + 608]).split(b'\0')[0]
print('原:', cmd[:120].decode(errors='replace'))
i = cmd.find(b'cpus=7')
assert i >= 0
b[base + i:base + i + 6] = b'cpus=6'
p.write_bytes(bytes(b))
cmd2 = bytes(b[base:base + 608]).split(b'\0')[0]
print('新:', cmd2[:120].decode(errors='replace'))
PY
