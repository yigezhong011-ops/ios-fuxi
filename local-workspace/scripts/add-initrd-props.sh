#!/bin/bash
set -euo pipefail
for B in /mnt/e/DSH-Fuxi/unixnu/fuxi-board.toml /root/UniXNU-fuxi/board.toml; do
python3 - "$B" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
if 'linux,initrd-start' in t:
    print(p, 'already patched')
    raise SystemExit
block = '''
[[bootimg.dtb_node]]
path = "/chosen"
props = [
  { name = "linux,initrd-start", type = "x", value = ["0x0", "0xA8000000"] },
  { name = "linux,initrd-end", type = "x", value = ["0x0", "0xB4000000"] },
]
'''
t = t.rstrip() + "\n" + block
p.write_text(t)
print(p, 'patched with initrd props')
PY
done
grep -n -A5 'linux,initrd-start' /root/UniXNU-fuxi/board.toml | head -8
