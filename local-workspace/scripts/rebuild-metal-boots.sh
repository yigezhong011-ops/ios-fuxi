#!/bin/bash
# Rebuild both Metal boot images with a boot-uuid boot argument.
# The backboardd gate refuses with "boot-uuid-unavailable" when the kernel has no
# boot session UUID, and XNU accepts boot-uuid=<value> as a boot argument.
set -euo pipefail
UUID=f0c10000-0000-4000-8000-0000b007b007
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi

build_one() {
  local mode=$1 out=$2
  local CMDLINE
  CMDLINE=$(python3 - "$PKG/payload.bin" "$mode" "$UUID" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
mode, uuid = sys.argv[2], sys.argv[3]
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6').replace(' sweetfb_noconsole=1', '')
cmd = ' '.join(a for a in cmd.split() if not a.startswith(('fuxibbgpu=', 'boot-uuid=')))
cmd += ' fuxibbgpu=%s boot-uuid=%s' % (mode, uuid)
print(cmd)
PY
)
  echo "--- $out ---"
  echo "$CMDLINE" | tr ' ' '\n' | grep -E 'fuxibbgpu|boot-uuid|cpus=' | sed 's/^/    /'
  python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" >/dev/null 2>&1
  printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
  ( cd "$B"
    export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
    clang $CFLAGS -c payload.S -o payload.o
    ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
    llvm-objcopy -O binary loader.elf Image
    python3 "$SRC/packboot4.py" "$B/Image" "$out" )
  ls -lh "$out"
}

build_one 1 /mnt/e/DSH-Fuxi/fuxi-metal-boot.img
build_one 2 /mnt/e/DSH-Fuxi/fuxi-metal-survey.img
echo METAL_BOOTS_OK
