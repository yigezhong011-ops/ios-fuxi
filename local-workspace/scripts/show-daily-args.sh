#!/bin/bash
# Show the GPU-related boot args of the extracted daily volume.
set -uo pipefail
V=/root/fuxi/nopause/vol.img
export MTOOLS_SKIP_CHECK=1
mtype -i "$V" ::/EFI/UniXNU/unixnu.toml > /root/fuxi/nopause/toml.now
python3 - <<'PY'
import re
from pathlib import Path
t = Path('/root/fuxi/nopause/toml.now').read_text()
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()
print('参数总数', len(args), '，字符数', len(m.group(1)))
print('GPU/显示相关:')
for a in args:
    if any(k in a for k in ('gpu', 'vsync', 'dpu', '120', 'coherent', 'mailbox', 'wc')):
        print('   ', a)
PY
