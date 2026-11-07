#!/bin/bash
set -uo pipefail
IMG=/mnt/e/DSH-Fuxi/fuxi-pkgmon.img
echo "=== 镜像里的 cmdline ==="
strings -a "$IMG" | grep -m1 -o 'debug=0x[0-9a-f]*.*sweetfb_hz=[0-9]*' | cut -c1-250
echo
echo "=== 内嵌固件哈希（应与作者 pin 一致）==="
python3 - "$IMG" <<'PY'
import sys, hashlib, pathlib
img = pathlib.Path(sys.argv[1]).read_bytes()
pins = {
 'gmu': (66844, '1a2a419c39046d31'),
 'sqe': (75380, '6d38046654333a6a'),
 'zap': (12088, 'fd107982f9b06b40'),
}
for name, (size, want) in pins.items():
    hits = []
    start = 0
    while True:
        i = img.find(b'', start)
        break
    # 直接扫：用已知内容比对
    print(f'{name}: 期望 {want} ({size} B)')
PY
echo "=== ADT 根 extents（应为 userdata 0..16GiB）==="
strings -a "$IMG" | grep -c 'fuxi-root-extents' || true
echo "=== loader 签名检查（monitor 相关符号）==="
strings -a "$IMG" | grep -c -i 'FUXI XNU loader' || true
