#!/bin/bash
# How much room is there after copyio_test before the next symbol begins?
set -uo pipefail
K=/root/fuxi/t50-usbfast/kernel.macho
llvm-nm --defined-only "$K" 2>/dev/null | awk 'NF >= 3 {print $1" "$3}' > /root/fuxi/t50-all-syms.txt
python3 - <<'PY'
from pathlib import Path
rows = []
for line in Path('/root/fuxi/t50-all-syms.txt').read_text().splitlines():
    parts = line.split()
    if len(parts) == 2:
        try:
            rows.append((int(parts[0], 16), parts[1]))
        except ValueError:
            pass
rows.sort()
for i, (a, name) in enumerate(rows):
    if name == '_copyio_test':
        print('copyio_test 0x%x' % a)
        for j in range(i + 1, min(i + 4, len(rows))):
            print('  之后 0x%x %s（+%d）' % (rows[j][0], rows[j][1], rows[j][0] - a))
        break
else:
    print('没找到 _copyio_test')
PY
