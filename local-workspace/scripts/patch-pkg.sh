#!/bin/bash
set -euo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working

echo "=== 1) simg 卷头 H+Lx -> HFSJ ==="
printf 'HFSJ' | dd of="$P/ios16-root-v11-fixed.simg" bs=1 seek=1072 conv=notrunc status=none 2>/dev/null || true
cp "$P/ios16-root-v11.simg" "$P/ios16-root-v11-fixed.simg"
printf 'HFSJ' | dd of="$P/ios16-root-v11-fixed.simg" bs=1 seek=1072 conv=notrunc status=none
xxd -l 16 -s 1064 "$P/ios16-root-v11-fixed.simg"

echo "=== 2) boot 镜像 cpus=7 -> cpus=6 ==="
cp "$P/boot-gpu3-v4.img" "$P/boot-gpu3-cpus6.img"
python3 - "$P/boot-gpu3-cpus6.img" <<'PY'
import sys
p = sys.argv[1]
BASE = 544784 + 0x48
with open(p, 'r+b') as f:
    f.seek(BASE)
    cmd = f.read(608)
    print('原 cmdline:', cmd.split(b'\0')[0].decode(errors='replace')[:160])
    i = cmd.find(b'cpus=7')
    assert i >= 0, 'cpus=7 not found in cmdline'
    f.seek(BASE + i)
    f.write(b'cpus=6')
    f.seek(BASE)
    print('新 cmdline:', f.read(608).split(b'\0')[0].decode(errors='replace')[:160])
PY
ls -l "$P"/ios16-root-v11-fixed.simg "$P"/boot-gpu3-cpus6.img
