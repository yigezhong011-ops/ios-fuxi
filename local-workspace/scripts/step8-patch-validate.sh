#!/bin/bash
set -euo pipefail
cd /root/ios-fuxi
python3 - <<'PY'
from pathlib import Path
p = Path('/root/ios-fuxi/tools/mkadt-fuxi.py')
s = p.read_text()
old = """    if not any(base <= PHYS_BASE and PHYS_BASE + BANK_SIZE <= base + size for base, size in ranges):
        raise ValueError('requested XNU RAM is outside advertised memory')"""
new = """    # A device may advertise the DDR bank as several adjacent ranges (this fuxi
    # reports 3 GiB at 0x8c0000000 followed by 6 GiB at 0x980000000), so test the
    # union instead of demanding one range that contains the whole window.
    cover = sorted((b, b + z) for b, z in ranges)
    end = PHYS_BASE
    for b, e in cover:
        if b <= end < e:
            end = e
    if not (end >= PHYS_BASE + BANK_SIZE):
        raise ValueError('requested XNU RAM is outside advertised memory')"""
assert old in s
p.write_text(s.replace(old, new))
print('patched validate_live union check')
PY
python3 tools/mkadt-fuxi.py /tmp/fuxi-test.adt --live-fdt /tmp/live.fdt \
  --root-extents /tmp/ext.json --root-bytes 8388608 --gpu-reserve --smp 2>&1 | tail -6
ls -l /tmp/fuxi-test.adt
python3 - <<'PY'
b = open('/tmp/fuxi-test.adt','rb').read()
for pat in (b'sweet-ufs', b'fuxi-ufs', b'fuxi-root-extents', b'fuxi-root-blocks'):
    print(pat.decode(), '->', ('0x%x' % b.find(pat)) if b.find(pat) >= 0 else 'not found')
PY
