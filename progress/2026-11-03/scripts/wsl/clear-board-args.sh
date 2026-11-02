#!/bin/bash
set -uo pipefail
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
echo "=== board.toml 的 kernel_args ==="
awk '/^kernel_args = \[/,/^\]/' "$DEV/board.toml" | head -12 | cut -c1-100
echo "行数: $(awk '/^kernel_args = \[/,/^\]/' "$DEV/board.toml" | wc -l)"

python3 - "$DEV/board.toml" <<'PY'
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
text = p.read_text()
m = re.search(r'^kernel_args = \[.*?^\]\n', text, re.S | re.M)
if not m:
    sys.exit('没有 kernel_args 块')
old = m.group(0)
print('原块 %d 字节' % len(old))
p.write_text(text.replace(old, 'kernel_args = []\n', 1))
print('已清空，改由 --kernel-arg 传入')
PY
awk '/^kernel_args = /{print; exit}' "$DEV/board.toml"
