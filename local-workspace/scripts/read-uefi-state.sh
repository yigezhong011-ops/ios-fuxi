#!/bin/bash
# Read-only: where a firmware tree can build, whether the current loader matches any built FD, and whether the power driver exists.
set -u
for d in /root/fuxi-build/uefi-fuxi /root/fuxi/uefi-fuxi /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi; do
  [ -d "$d" ] || continue
  echo "== $d"; git -C "$d" log -1 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-100; git -C "$d" status -sb 2>/dev/null | head -8 | cut -c1-90
  grep -n 'FUXI_USB_POWER' "$d/Platforms/Xiaomi/fuxiPkg/fuxi.dsc" "$d/Platforms/Xiaomi/fuxiPkg/Include/DXE.inc" 2>/dev/null | head -5
  find "$d" -maxdepth 4 -type d -name UsbPwrEnablerDxe 2>/dev/null | head -3
  find "$d" -type f -name 'UsbPwrEnablerDxe*' 2>/dev/null | head -5
  find "$d/Build" -name 'SILICIUM_UEFI.fd' -printf '%TY-%Tm-%Td %TH:%TM %s %p\n' 2>/dev/null | head -5
  ls "$d/scripts" 2>/dev/null | head -12
done
ls -d /root/fuxi-build/* 2>/dev/null | head; ls /root/fuxi-build/UniXNU/out/fuxi 2>/dev/null | head
echo '== loader in the current image'
python3 -I - /mnt/e/DSH-Fuxi/t50-daily-usb.img <<'PY'
import hashlib, struct, sys, zlib
d = open(sys.argv[1], 'rb').read()
k = struct.unpack_from('<I', d, 8)[0]
b = zlib.decompressobj(16 + zlib.MAX_WBITS).decompress(d[4096:4096 + k])
base = next(x for x in range(0, 8 << 20, 2) if b[x + 0x52:x + 0x5a].startswith(b'FAT32') and b[x + 0x1fe:x + 0x200] == b'\x55\xaa')
fd = b[192:base]
print('loader', base, 'shim sha', hashlib.sha256(b[:192]).hexdigest()[:16], 'fd', len(fd), hashlib.sha256(fd).hexdigest()[:16])
open('/tmp/current.fd', 'wb').write(fd)
for s in (b'UsbPwrEnabler', b'UsbInitDxe', b'UFSDxe', b'FuxiUfsLogDxe', b'AdvancedLog', b'DEBUG', b'RELEASE'):
    print(s.decode(), fd.count(s))
PY
find /root /mnt/e/DSH-Fuxi -maxdepth 6 -type f -name '*.fd' -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null | grep -v '/待删除/' | head -10 | while read -r l; do p=${l##* }; echo "$l $(sha256sum "$p" | cut -c1-16)"; done
which clang lld nasm iasl python3 2>/dev/null | tr '\n' ' '; echo; df -h /root | tail -1
