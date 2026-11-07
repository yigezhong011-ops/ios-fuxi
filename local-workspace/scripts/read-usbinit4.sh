#!/bin/bash
# Read-only: StartController in UsbInitDxe, and its protocol's revision words.
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/decode-shot.py /mnt/e/DSH-Fuxi/logs/shot-t50-auto-gpu7-213710-2
awk '/^ +5b8:/{p=1} /^ +6c4:/{p=0} p' /root/fuxi/usbinit.dis | sed -E 's/<[^>]*>//' | cut -c5-50
python3 -I - <<'PY'
import struct
d = open('/tmp/ui.text', 'rb').read()
print('words at 0x2ff0', [hex(x) for x in struct.unpack_from('<QQ', d, 0x2ff0)])
PY
date +%T
