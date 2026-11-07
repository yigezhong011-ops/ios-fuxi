#!/bin/bash
set -uo pipefail
B=/root/UniXNU/scripts/unixnu/bootimg.py
python3 - "$B" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
old = "    if requires_header and (shim[56:60] != b'ARM\\x64' or struct.unpack_from('<QQ', shim, 8) != (base, len(shim) + size)):"
if 'DEBUG shim' not in t:
    new = ("""    if requires_header:
        import sys as _sys
        _h = struct.unpack_from('<QQ', shim, 8)
        print(f"DEBUG shim: len={len(shim)} hdr=(text_off={_h[0]:#x}, image_size={_h[1]:#x}) "
              f"expected=(base={base:#x}, {len(shim)+size:#x}) magic={shim[56:60]!r}", file=_sys.stderr)
    if requires_header and (shim[56:60] != b'ARM\\x64' or struct.unpack_from('<QQ', shim, 8) != (base, len(shim) + size)):""")
    assert old in t, 'verify anchor missing'
    t = t.replace(old, new, 1)
    p.write_text(t)
    print('bootimg debug print added')
else:
    print('already patched')
PY
cd /root/UniXNU
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
python3 ./unixnu bootimg -D /root/UniXNU-fuxi --uefi /root/uefi-fuxi \
  --fd /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd \
  --dtb "$OUT/device-tree/hardware.dtb" \
  --ramdisk "$OUT/payload/payload.img" \
  -o "$OUT/boot/boot.img" 2>&1 | grep -E 'DEBUG shim|error|unixnu:' | head -5
