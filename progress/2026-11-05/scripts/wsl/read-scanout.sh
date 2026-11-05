#!/bin/bash
# Print the full [scanout prepare] counter blocks from the kernel log window.
set -uo pipefail
B=/mnt/e/DSH-Fuxi/logs/carve-coh2/log.bin
python3 - "$B" <<'PY'
import re, sys
from pathlib import Path
data = Path(sys.argv[1]).read_bytes().replace(b'\0', b'')
text = data.decode('latin-1')
blocks = []
for m in re.finditer(r'\[scanout prepare\]', text):
    tail = text[m.end():m.end() + 400]
    line = tail.split('\n')[1] if '\n' in tail else tail
    blocks.append(line.strip())
print('共 %d 个 [scanout prepare] 块，展示最后 6 个：' % len(blocks))
for b in blocks[-6:]:
    print('  ', b[:260])

hexes = [b for b in blocks if 'prepare calls=' in b]
if hexes:
    last = hexes[-1]
    def num(k):
        m = re.search(k + r'=(\d+)', last)
        return int(m.group(1)) if m else None
    calls, fails = num('prepare calls'), num('failures')
    waited, sent, arms = num('waited_ms'), num('sent'), num('arms')
    idle, late = num('idle'), num('late')
    print('\n最后一次: calls=%s failures=%s waited_ms=%s sent=%s arms=%s idle=%s late=%s'
          % (calls, fails, waited, sent, arms, idle, late))
    if calls and sent is not None:
        print('  平均每次 prepare 送出的帧: %.2f' % (sent / calls if calls else 0))
PY
