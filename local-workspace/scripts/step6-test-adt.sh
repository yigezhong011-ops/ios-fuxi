#!/bin/bash
set -euo pipefail
cd /root/ios-fuxi
cp /mnt/e/DSH-Fuxi/dump/fuxi-dump/fdt /tmp/live.fdt
cat > /tmp/ext.json <<'EOF'
{"size":8388608,"extents":[[0,4182815,2048]]}
EOF
cat /tmp/ext.json
python3 tools/mkadt-fuxi.py /tmp/fuxi-test.adt --live-fdt /tmp/live.fdt \
  --root-extents /tmp/ext.json --root-bytes 8388608 --gpu-reserve --smp 2>&1 | tail -8
ls -l /tmp/fuxi-test.adt
python3 - <<'PY'
b=open('/tmp/fuxi-test.adt','rb').read()
for p in (b'sweet-ufs', b'fuxi-ufs', b'fuxi-root-extents', b'fuxi-root-blocks', b'D22AP'):
    print(p.decode(), '->', ('0x%x' % b.find(p)) if b.find(p) >= 0 else 'not found')
PY
