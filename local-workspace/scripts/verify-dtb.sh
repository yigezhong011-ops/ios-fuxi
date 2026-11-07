#!/bin/bash
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/unixnu-boot.img
python3 - "$IMG" <<'PY'
import pathlib, struct, sys
d = pathlib.Path(sys.argv[1]).read_bytes()
magic = struct.pack('>I', 0xD00DFEED)
idx = d.rfind(magic)
print('boot.img size:', len(d))
print('DTB magic at:', hex(idx) if idx >= 0 else 'NOT FOUND')
if idx >= 0:
    size = struct.unpack_from('>I', d, idx + 4)[0]
    print('DTB size:', size)
    pathlib.Path('/root/dtb-from-boot.img').write_bytes(d[idx:idx+size])
    # search the initrd property name in the DTB
    for name in (b'linux,initrd-start', b'linux,initrd-end'):
        print(name, b'present' if name in d[idx:idx+size] else b'MISSING')
PY
echo "=== 反编译这段 DTB 的 /chosen ==="
dtc -I dtb -O dts /root/dtb-from-boot.img 2>/dev/null | grep -A6 'chosen' | head -12
