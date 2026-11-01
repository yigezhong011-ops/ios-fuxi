#!/bin/bash
# What is scratch-data.img in the t32 payload (the Data seed?): type, header, and any MobileGestalt traces.
set -euo pipefail
W=/root/fuxi/t32
export MTOOLS_SKIP_CHECK=1
mcopy -o -i "$W/vol.img" ::/EFI/UniXNU/Payloads/scratch-data.img "$W/scratch-data.img"
ls -l "$W/scratch-data.img"
file "$W/scratch-data.img"
xxd -l 96 "$W/scratch-data.img"
echo "== magic scan (APFS NXSB / HFS+ H+ / gzip / LZFSE bvx / bplist)"
python3 -I - "$W/scratch-data.img" <<'PY'
import sys
d = open(sys.argv[1], 'rb').read()
for name, magic in (('APFS NXSB', b'NXSB'), ('APFS APSB', b'APSB'), ('HFS+', b'H+\x00\x04'), ('gzip', b'\x1f\x8b\x08'),
                    ('lzfse', b'bvx2'), ('bplist', b'bplist00'), ('xml plist', b'<?xml')):
    offs, i = [], d.find(magic)
    while i != -1 and len(offs) < 5:
        offs.append(hex(i)); i = d.find(magic, i + 1)
    print(f'  {name:10} {d.count(magic):5}  first {offs}')
for s in (b'MobileGestalt', b'mobilegestalt', b'DeviceClass', b'SBDisable', b'SetupDone', b'com.apple.purplebuddy'):
    print(f'  {s.decode():24} {d.count(s)}')
PY
strings -n 10 "$W/scratch-data.img" | head -30
