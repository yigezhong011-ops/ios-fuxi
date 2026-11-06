#!/usr/bin/env python3
"""Move the cave past copyio_test's first page and raise its size limit."""
from pathlib import Path

p = Path('/mnt/e/DSH-Fuxi/dump/wsl/make-t50-touch.sh')
t = p.read_text()
old_cave = 'CAVE=$(sym _copyio_test); CHECK=$(sym _native_legacy_gop_mapping_checkpoint)'
new_cave = (
    'CAVE0=$(sym _copyio_test); CHECK=$(sym _native_legacy_gop_mapping_checkpoint)\n'
    '# copyio_test has about 19.6 KB before the next function; stay out of its first page.\n'
    'CAVE=$(python3 -c "print(hex($CAVE0 + 0x1000))")\n'
    'echo "cave base $CAVE"'
)
assert old_cave in t
t = t.replace(old_cave, new_cave)
t = t.replace('if not 0 < len(c) <= 1024:', 'if not 0 < len(c) <= 8192:')
t = t.replace(
    "raise SystemExit(f'cave size {len(c)} > 1024 (the window table starts at +0x400)')",
    "raise SystemExit(f'cave size {len(c)} > 8192')",
)
p.write_text(t)
print('patched')
for line in p.read_text().splitlines():
    if 'CAVE' in line or '8192' in line:
        print('  ', line.strip()[:100])
