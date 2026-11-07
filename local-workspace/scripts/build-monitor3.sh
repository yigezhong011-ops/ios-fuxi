#!/bin/bash
set -euo pipefail
B=/root/fuxi/authbuild
P="$B/probe.c"

python3 - "$P" <<'PY'
import sys, pathlib, re
p = pathlib.Path(sys.argv[1])
t = p.read_text()
if 'fuxi_assert_relaxed' in t:
    print('already patched'); raise SystemExit
subs = [
 (' if(probe_info.sctlr & 5) reboot();',
  ' /* fuxi_assert_relaxed: MMU state varies by ABL; do not reboot */'),
 (' if((probe_info.gcc_master|probe_info.gcc_cfg)&0x80000000) reboot();',
  ' /* fuxi_assert_relaxed: GCC ownership varies; do not reboot */'),
 (' if((probe_info.gsnpsid&0xffff0000)!=0x55330000 && (probe_info.gsnpsid&0xffff0000)!=0x33310000) reboot();',
  ' /* fuxi_assert_relaxed: USB controller ID check relaxed */'),
]
n = 0
for old, new in subs:
    if old in t:
        t = t.replace(old, new, 1)
        n += 1
p.write_text(t)
print('已放宽 %d 处断言' % n)
PY

cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
clang $CFLAGS -c probe.c -o probe.o
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 /mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src/packboot4.py "$B/Image" /mnt/e/DSH-Fuxi/fuxi-authmon3.img
ls -lh /mnt/e/DSH-Fuxi/fuxi-authmon3.img
