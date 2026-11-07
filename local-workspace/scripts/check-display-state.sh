#!/bin/bash
set -uo pipefail
for D in /root/fuxi/mon23 /root/fuxi/mon24; do
  echo "=== $D ==="
  ls "$D" 2>/dev/null | head -8
  if [ -f "$D/display-after.bin" ]; then
    python3 - "$D/display-after.bin" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
print('display-after.bin:', len(d), 'bytes')
w = struct.unpack('<%dI' % (len(d)//4), d[:len(d)//4*4])
print(' '.join(f'{x:08x}' for x in w[:24]))
PY
  fi
  echo
done
