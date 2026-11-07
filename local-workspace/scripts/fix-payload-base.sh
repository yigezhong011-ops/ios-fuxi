#!/bin/bash
set -euo pipefail
H=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.h
python3 - "$H" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = '#define XNU_PAYLOAD_BASE      0xF0000000ULL'
new = '#define XNU_PAYLOAD_BASE      0xA8000000ULL'
if new in t:
    print('already fuxi')
elif old in t:
    p.write_text(t.replace(old, new, 1))
    print('patched to 0xA8000000')
else:
    print('ERROR: anchor not found'); sys.exit(1)
PY
echo "--- 现在的值 ---"
grep -n 'XNU_PAYLOAD_BASE' "$H"
