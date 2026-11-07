#!/bin/bash
# Re-arm the backboardd gate (it latches denied per boot UUID) with a fresh UUID,
# console on so the failure point is visible.
set -euo pipefail
UUID=$(python3 -c "import uuid;print(uuid.uuid4())")
B=/root/fuxi/ownbuild
SRC=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src
ADT=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/fuxi-root.adt
PKG=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working
KERNEL=/mnt/e/DSH-Fuxi/kernel-inject/kernel.development.fuxi
OUT=/mnt/e/DSH-Fuxi/fuxi-metal-arrearm.img

CMDLINE=$(python3 - "$PKG/payload.bin" "$UUID" <<'PY'
import sys
b = open(sys.argv[1], 'rb').read()
uuid = sys.argv[2]
cmd = b[0x48:0x48+608].split(b'\0')[0].decode(errors='replace')
cmd = cmd.replace('cpus=7', 'cpus=6').replace(' sweetfb_noconsole=1', '')
cmd = ' '.join(a for a in cmd.split() if not a.startswith(('fuxibbgpu=', 'boot-uuid=')))
cmd += ' fuxibbgpu=1 boot-uuid=%s' % uuid
print(cmd)
PY
)
echo "=== 新 boot-uuid: $UUID ==="
echo "$CMDLINE" | tr ' ' '\n' | grep -E 'fuxibbgpu|boot-uuid|cpus=|noconsole' | sed 's/^/  /'

python3 /root/ios-fuxi/tools/mkpayload.py "$KERNEL" "$ADT" "$B/payload.bin" --cmdline "$CMDLINE" >/dev/null 2>&1
printf '.section .payload,"a"\n.incbin "%s/payload.bin"\n' "$B" > "$B/payload.S"
cd "$B"
export CFLAGS="--target=aarch64-none-elf -O2 -ffreestanding -fno-builtin -nostdlib -fno-pic -fno-stack-protector -mgeneral-regs-only -mstrict-align -Wall -Wextra -Wno-unterminated-string-initialization -DFUXI=1 -DFUXI_XNU_LOADER=1 -I$B -I/root/ios-fuxi/shim -I/root/ios-fuxi/shim/fuxi-probe"
clang $CFLAGS -c payload.S -o payload.o
ld.lld -T loader.ld --build-id=none start.o loader.o console.o probe.o gpu-fw.o payload.o -o loader.elf
llvm-objcopy -O binary loader.elf Image
python3 "$SRC/packboot4.py" "$B/Image" "$OUT"
ls -lh "$OUT"
echo ARREARM_OK
