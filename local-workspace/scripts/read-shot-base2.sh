#!/bin/bash
# Read-only: the screenshot capture contract, where GPU frames live, and whether anything refers to copyio_test.
set -u
Q=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/drivers/QcomXnuUsbDebug; P=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/package; A=/root/fuxi/t50.dis; K=/root/fuxi/t50/kernel.macho
echo '== local module rev'; git -C "$Q" log -1 --format='%h %ad %s' --date=short 2>/dev/null | cut -c1-100
echo '== QcomUsbScreenshot.c'; wc -l "$Q/kernel/QcomUsbScreenshot.c"
grep -n -E 'capacity|QCOM_USB_SHOT|MAX|provider|capture|encoding|rle|deflate|width|height' "$Q/kernel/QcomUsbScreenshot.c" | cut -c1-120 | head -50
grep -n -E 'QCOM_USB_SHOT|MAX|capture|typedef' "$Q/include/QcomUsbScreenshot.h" | cut -c1-120 | head -20
echo '== host decoder'; grep -n -E 'encoding|def |decompress|rle|timeout' "$Q/scripts/screenshot.py" | cut -c1-110 | head -30
echo '== current frame in source'
grep -rn -E 'native_legacy_swap_surface|native_legacy_presented_generation|native_legacy_swap_request\b' "$P" 2>/dev/null | cut -c1-170 | head -14
ls "$P" | grep -i -E 'display|legacy|scanout|gpu' | head -20
grep -rln -E 'GpuScanoutPresenter|scanoutPresent|presentSurface' "$P" /mnt/e/DSH-Fuxi/unixnu-build/fuxi/drivers 2>/dev/null | head
echo '== finishGpuSwap disassembly'; awk 'index($0,"<__ZN19NativeLegacyDisplay13finishGpuSwapEi>:"){p=1} p{print; c++} p&&/^$/{exit} c>70{exit}' "$A" | cut -c1-105
echo '== copyio_test references'
grep -n -E '0xfffffff00bdf1130' "$A" | cut -c1-110 | head
llvm-nm "$K" 2>/dev/null | grep -E ' _?(copyio_test|sysctl_copyio_test|testing_copyio)' | head
grep -n -E 'adrp.*0xfffffff00bdf1000' "$A" | cut -c1-110 | head -8
strings -a "$K" | grep -E 'copyio_test|copyio test' | head -5
python3 -I - "$K" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read()
v = struct.pack('<Q', 0xfffffff00bdf1130)
at, n = 0, 0
while True:
    at = d.find(v, at)
    if at < 0:
        break
    print('raw pointer at file', hex(at)); at += 8; n += 1
print('raw pointers', n)
low = struct.pack('<I', 0xfffffff00bdf1130 & 0xffffffff)
print('low 32 hits', d.count(low))
PY
