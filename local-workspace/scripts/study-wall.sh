#!/bin/bash
# Does the running addon carry a wallpaper overlay, and what would one need? Read-only.
export MTOOLS_SKIP_CHECK=1
python3 -I - <<'EOF'
import struct, subprocess, zlib
blob = subprocess.run(['mtype', '-i', '/root/fuxi/gpu-new-t50-mine/vol.img', '::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'], capture_output=True).stdout
print('addon bytes', len(blob), blob[:8])
count, _, total = struct.unpack_from('<IIQ', blob, 8)
off = 24
pad8 = lambda n: n + (-n % 8)
for _ in range(count):
    nlen, mode, size, csize = struct.unpack_from('<IIQQ', blob, off); off += 24
    name = blob[off:off + nlen - 1].decode(); off += pad8(nlen)
    print(f'  {size:10d} {csize:10d} {oct(mode)} {name}')
    off += pad8(csize)
print('used', off, 'declared', total)
EOF
mdir -i /root/fuxi/gpu-new-t50-mine/vol.img ::/EFI/UniXNU/Payloads | cut -c1-70 | head -14
strings -a /root/fuxi/t50-mine/kernel.macho | grep -E 'ngpu|Wallpaper|J120|7570' | cut -c1-150 | sort -u | head -14
ls -la /mnt/e/DSH-Fuxi/wallpaper-overlay
sed -n 1,40p /mnt/e/DSH-Fuxi/wallpaper-overlay/index.xml | cut -c1-120 | head -14
grep -a -E '7570|iPadOS_17' /mnt/e/DSH-Fuxi/dump/root-peek/list.txt | grep -a -E '\.ca$|\.heic|main.caml|\.png' | cut -c20-175 | head -14
python3 -I -c "
import plistlib,sys
" ; ls -d /mnt/e/DSH-Fuxi/*/ | grep -i -E 'fuxi|ios' ; find /mnt/e/DSH-Fuxi /root/fuxi -maxdepth 3 -type d -name .git 2>/dev/null | head
