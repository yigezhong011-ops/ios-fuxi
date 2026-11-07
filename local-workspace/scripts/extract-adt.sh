#!/bin/bash
set -euo pipefail
W=/root/fuxi/build-x
OUT=/root/ios-fuxi/research/ipsw-x
mkdir -p "$OUT"
python3 - "$W/DeviceTree.d22ap.im4p" "$OUT/d22ap.adt" <<'PY'
import lzfse, sys, pathlib
src, dst = sys.argv[1], sys.argv[2]
d = pathlib.Path(src).read_bytes()
i = d.find(b'bvx2')
if i < 0:
    raise SystemExit('no bvx2 LZFSE stream found')
raw = lzfse.decompress(d[i:])
print('decompressed ADT bytes:', len(raw))
pathlib.Path(dst).write_bytes(raw)
print('wrote', dst)
# sanity: an ADT starts with the "device tree" magic; show the first words
import struct
print('first 16 bytes:', raw[:16].hex())
PY
ls -l "$OUT/d22ap.adt"
