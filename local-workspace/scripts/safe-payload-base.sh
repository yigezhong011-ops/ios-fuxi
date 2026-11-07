#!/bin/bash
set -euo pipefail
H=/root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.h
python3 - "$H" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
t = re.sub(r'#define XNU_PAYLOAD_BASE\s+0x[0-9A-Fa-f]+ULL',
           '#define XNU_PAYLOAD_BASE      0xA7000000ULL', t, count=1)
p.write_text(t)
print('XNU_PAYLOAD_BASE -> 0xA7000000 (mapped FD-reserved window)')
PY
grep -n 'XNU_PAYLOAD_BASE' "$H"
touch /root/uefi-fuxi/Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/XnuLoader.c
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/fw-xnu5.log 2>&1
echo "FW_EXIT=$?"
grep -c 'error' /root/fw-xnu5.log || true
ls -l --time-style=+%H:%M /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd

cd /root/hackios
python3 xnuloader/mkpayload.py -o out/hello-payload.bin loader.efi=out/hello.efi --usb
FD=/root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
FD_BASE=0xA7100000 FD_SIZE=0x300000 PAYLOAD_BASE=0xA7000000 UEFI_TARGET=fuxi UEFI_FD=$FD \
python3 mkxnuimg.py -p out/hello-payload.bin -o out/fuxi-hello-c.img 2>&1 | tail -2
cp out/fuxi-hello-c.img /mnt/e/DSH-Fuxi/fuxi-hello-c.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-hello-c.img
