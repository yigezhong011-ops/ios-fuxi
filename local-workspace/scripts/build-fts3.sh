#!/bin/bash
# Like build-fts2.sh, but take kernel + ADT from the CI payload so they match.
# fts2 paired the OddlyLabs kernel with the author's ADT and hung right after handoff.
# Usage: build-fts3.sh [kernel.macho [out-name [adt]]]  (default: CI kernel + CI ADT -> unixnu-fts3.img)
# fts4 = this with the panic-screen-patched kernel from patch-panic-fts4.sh.
set -euo pipefail
KERNEL=${1:-}
OUT=${2:-unixnu-fts3}
ADT=${3:-}
W=/root/fuxi/pkg-$OUT
rm -rf "$W"; mkdir -p "$W/root/EFI/UniXNU/Payloads"
cd "$W"
export MTOOLS_SKIP_CHECK=1

echo "=== 从 CI payload 取内核 + 配套 ADT + toml ==="
if [ -n "$KERNEL" ]; then
  cp "$KERNEL" "$W/root/EFI/UniXNU/Payloads/kernel.macho"
else
  mcopy -i /root/fuxi/ci-payload.img ::/EFI/UniXNU/Payloads/kernel.macho "$W/root/EFI/UniXNU/Payloads/"
fi
if [ -n "$ADT" ]; then
  cp "$ADT" "$W/root/EFI/UniXNU/Payloads/kernel.macho.adt"
else
  mcopy -i /root/fuxi/ci-payload.img ::/EFI/UniXNU/Payloads/kernel.macho.adt "$W/root/EFI/UniXNU/Payloads/"
fi
mcopy -i /root/fuxi/ci-payload.img ::/EFI/UniXNU/unixnu.toml               "$W/root/EFI/UniXNU/"
ls -l "$W/root/EFI/UniXNU/Payloads"

echo "=== 改参数 ==="
python3 - "$W/root/EFI/UniXNU/unixnu.toml" <<'PY'
import re, sys
p = sys.argv[1]
t = open(p, encoding='utf-8').read()
m = re.search(r'args = "([^"]*)"', t)
want = {'fuxi-touch': '4', 'fuxi-touch-panic': '1'}
args = [a for a in m.group(1).split() if a.split('=')[0] not in want]
args += ['%s=%s' % kv for kv in want.items()]
t = t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]
open(p, 'w', encoding='utf-8').write(t)
print('args:', ' '.join(args))
PY

echo "=== 新卷 ==="
IMG="$W/payload.img"
rm -f "$IMG"
# VOL_MIB overrides the volume size (default 176 MiB as in user-boot.img).
truncate -s $(( ${VOL_MIB:-176} * 1024 * 1024 )) "$IMG"
mformat -i "$IMG" -F -v FUXIESP ::
mcopy -i "$IMG" -s "$W/root/EFI" ::/
mdir -i "$IMG" ::/EFI/UniXNU/Payloads | tail -6

python3 - "$W" <<'PY'
import gzip, sys
from pathlib import Path
w = Path(sys.argv[1])
body = Path('/root/fuxi/userboot/body.bin').read_bytes()
fat = None
for m in range(0, 8 << 20, 2):
    bs = body[m:m + 512]
    if len(bs) == 512 and bs[0x52:0x5a].startswith(b'FAT32') and bs[0x1fe:0x200] == b'\x55\xaa':
        fat = m
        break
payload = (w / 'payload.img').read_bytes()
tree = Path('/root/fuxi/userboot/tree.dtb').read_bytes()
# ARM64 header text_offset -> 0. The loader at the start of body.bin copies its 3 MiB firmware to 0xa7100000
# itself, and the fuxi ABL answers "Load Error" to a header asking for that address (OddlyLabs board.toml;
# seen here from 17:23 on every image, user-boot.img included).
loader = bytearray(body[:fat])
loader[8:16] = bytes(8)
(w / 'Image.gz-dtb').write_bytes(gzip.compress(bytes(loader) + payload, mtime=0) + tree)
print('gzip 主体 %d 字节（原 payload 区 %d）' % ((w / 'Image.gz-dtb').stat().st_size, fat))
PY

printf '\0' > "$W/ramdisk1"
# No --os_version/--os_patch_level: user-boot.img carries 0 there, and at 17:23 the ABL started refusing
# images with 16.0.0/2026-08 ("Load Error") that it had booted earlier.
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --header_version 3 --pagesize 4096 \
  --kernel "$W/Image.gz-dtb" --ramdisk "$W/ramdisk1" -o "/mnt/e/DSH-Fuxi/$OUT.img" 2>&1 | tail -1
ls -lh "/mnt/e/DSH-Fuxi/$OUT.img"
echo "${OUT}_OK"
