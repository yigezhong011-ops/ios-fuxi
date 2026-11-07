#!/bin/bash
set -uo pipefail
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
python3 - "$OUT/boot/boot.img" <<'PY'
import struct, sys, pathlib
data = pathlib.Path(sys.argv[1]).read_bytes()[:64]
print('magic:', data[:8])
vals = struct.unpack_from('<10I', data, 8)
names = ['kernel_size','kernel_addr','ramdisk_size','ramdisk_addr','second_size','second_addr','tags_addr','page_size','header_version','os_version']
for n, v in zip(names, vals):
    print(f'{n:16} {v} (0x{v:x})')
PY
echo
echo "=== Mu 配置里的 bootimg 参数 ==="
grep -rn -A8 'bootimg' /root/uefi-fuxi/Resources/Configs/fuxi.toml 2>/dev/null | head -20
ls /root/uefi-fuxi/Resources/Configs/ | grep -i fuxi
