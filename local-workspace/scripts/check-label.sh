#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/unixnu/payload/ipados-17.7.11-21H461/fuxi/payload/payload.img
python3 - "$P" <<'PY'
import pathlib, sys, struct
d = pathlib.Path(sys.argv[1]).read_bytes()[:512]
print('oem/jump bytes:', d[0:3].hex())
print('bytes per sector:', struct.unpack_from('<H', d, 11)[0])
print('sectors per cluster:', d[13])
print('reserved sectors:', struct.unpack_from('<H', d, 14)[0])
print('num fats:', d[16])
print('root entries (16/32):', struct.unpack_from('<H', d, 17)[0])
print('total sectors 16/32:', struct.unpack_from('<H', d, 19)[0], struct.unpack_from('<I', d, 32)[0])
label = d[0x47:0x47+11]
print('volume label @0x47:', label, '->', label.rstrip(b' ').decode('ascii','replace'))
print('fat32 type string @0x52:', d[0x52:0x5A])
PY
echo
echo "=== 驱动里比较标签的代码 ==="
sed -n '60,120p' /root/uefi-fuxi/Platforms/Xiaomi/fuxiPkg/Drivers/FuxiRamDiskDxe/FuxiRamDiskDxe.c | grep -n -A6 -i 'label' | head -20
