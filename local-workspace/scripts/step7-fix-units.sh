#!/bin/bash
set -euo pipefail
cd /tmp
sed 's/, lb, pb, nb, e->fe_flags/, lb*4096ULL, pb*4096ULL, nb*4096ULL, e->fe_flags/' fiemap3.c > fiemapb.c
echo "--- patched printf ---"
grep -n 'lb\*4096' fiemapb.c || echo "(未匹配到，检查源文件)"
aarch64-linux-gnu-gcc -O2 -static -o fiemapb fiemapb.c
cp fiemapb /mnt/e/DSH-Fuxi/dump/tools/fiemap-bytes
ls -l fiemapb

echo "=== 用字节版重建 ADT 测试 ==="
cd /root/ios-fuxi
python3 - <<'PY'
import json
open('/tmp/ext.json','w').write(json.dumps({"size":8388608,"extents":[[0,4182815*4096,8388608]]}))
print(open('/tmp/ext.json').read())
PY
python3 tools/mkadt-fuxi.py /tmp/fuxi-test.adt --live-fdt /tmp/live.fdt \
  --root-extents /tmp/ext.json --root-bytes 8388608 --gpu-reserve --smp 2>&1 | tail -5
ls -l /tmp/fuxi-test.adt || true
python3 - <<'PY'
b=open('/tmp/fuxi-test.adt','rb').read()
for p in (b'sweet-ufs', b'fuxi-ufs', b'fuxi-root-extents', b'fuxi-root-blocks', b'D22AP'):
    print(p.decode(), '->', ('0x%x' % b.find(p)) if b.find(p) >= 0 else 'not found')
PY
