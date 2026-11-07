#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
python3 - "$P/boot-native-v4.img" <<'PY'
import sys, pathlib
img = pathlib.Path(sys.argv[1]).read_bytes()
i = img.find(b'SWEETXNU')
print('SWEETXNU @', i, 'payload 长度', len(img) - i)
payload = img[i:]
out = pathlib.Path('/root/fuxi/payload-native.bin')
out.write_bytes(payload)
cmd = payload[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
print('cmdline:', cmd[:230])
PY
ls -l /root/fuxi/payload-native.bin
