#!/bin/bash
# t50-auto-shot: t50-auto-usbfast plus a screenshot provider. Only copyio_test's first bytes and the checkpoint's ret change. Temp boot only; writes no partition.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; B=/root/fuxi/t50-usbfast; W=/root/fuxi/t50-shot
rm -rf "$W"; mkdir -p "$W"; cd "$W"; cp "$B/vol.img" vol.img
cp "$B/kernel.macho" kernel.old
N=/tmp/t50-syms-usbfast.txt; llvm-nm --defined-only kernel.old > "$N" 2>/dev/null
sym() { local a; a=$(grep -E " $1\$" "$N" | head -1 | cut -d' ' -f1); [ -n "$a" ] || { echo "missing $1" >&2; exit 1; }; echo "0x$a"; }
CAVE=$(sym _copyio_test); CHECK=$(sym _native_legacy_gop_mapping_checkpoint)
clang --target=aarch64-none-elf -Os -ffreestanding -fno-builtin -fno-stack-protector -mgeneral-regs-only -fno-pic -fno-unwind-tables -fno-asynchronous-unwind-tables -c $S/shot-cave.c -o cave.o \
  -DADDR_GOP_VIRTUAL=$(sym _native_legacy_gop_virtual)UL -DADDR_GOP_WIDTH=$(sym _native_legacy_gop_width)UL -DADDR_GOP_HEIGHT=$(sym _native_legacy_gop_height)UL \
  -DADDR_PE_CURRENT_CONSOLE=$(sym _PE_current_console)UL -DADDR_REGISTER_SCREENSHOT=$(sym _qcom_usb_debug_register_screenshot)UL
ld.lld -e shot_entry -Ttext=$CAVE --image-base=$CAVE -z max-page-size=4096 cave.o -o cave.elf
llvm-objcopy -O binary -j .text cave.elf cave.bin
llvm-size --format=sysv cave.elf | grep -E '\.(text|data|bss|rodata)' || true
ENTRY=$(llvm-nm cave.elf | grep -E ' T shot_entry$' | cut -d' ' -f1)
python3 -I - "$CAVE" "$CHECK" "0x$ENTRY" <<'PY'
import struct, sys
cave, check, entry = (int(x, 16) for x in sys.argv[1:4])
k = bytearray(open('kernel.old', 'rb').read())
c = open('cave.bin', 'rb').read()
if not 0 < len(c) <= 1024:
    raise SystemExit(f'cave size {len(c)}')
ncmds, segs, at = struct.unpack_from('<I', k, 16)[0], [], 32
for _ in range(ncmds):
    cmd, size = struct.unpack_from('<II', k, at)
    if cmd == 0x19:
        name = k[at + 8:at + 24].rstrip(b'\0').decode()
        vm, _vs, off, fs = struct.unpack_from('<QQQQ', k, at + 24)
        segs.append((vm, fs, off, name))
    at += size
def seg(va):
    for s in segs:
        if s[0] <= va < s[0] + s[1]:
            return s
    raise SystemExit(f'{va:#x} not in the file')
def foff(va):
    s = seg(va)
    return s[2] + va - s[0]
print('cave', hex(cave), 'in', seg(cave)[3], 'size', len(c), 'entry', hex(entry))
if 'TEXT_EXEC' not in seg(cave)[3] or seg(cave) != seg(cave + len(c)):
    raise SystemExit('cave is not inside executable text')
if entry < cave or entry >= cave + len(c):
    raise SystemExit('entry outside the cave')
if struct.unpack_from('<I', k, foff(check))[0] != 0xd65f03c0:
    raise SystemExit('checkpoint is not a bare ret')
k[foff(cave):foff(cave) + len(c)] = c
struct.pack_into('<I', k, foff(check), 0x14000000 | (((entry - check) // 4) & 0x3ffffff))
open('kernel.macho', 'wb').write(k)
PY
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.macho >/dev/null
mcopy -n -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho kernel.back; cmp kernel.back kernel.macho
echo "kernel bytes changed: $(cmp -l kernel.old kernel.macho | wc -l)"
llvm-objdump -d --no-show-raw-insn --start-address=$CHECK --stop-address=$(printf '0x%x' $((CHECK + 4))) kernel.macho | tail -1 | cut -c1-90
llvm-objdump -d --no-show-raw-insn cave.elf | cut -c1-80 | head -80
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
bash /tmp/make-t50-auto.sh "$W" 420 t50-auto-shot
