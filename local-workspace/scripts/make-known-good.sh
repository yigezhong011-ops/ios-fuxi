#!/bin/bash
set -euo pipefail
OUT=/mnt/e/DSH-Fuxi/known-good
mkdir -p "$OUT"
K=/mnt/e/DSH-Fuxi/ci/kernel-diag/kernel.development.fuxi
[ -f "$K" ] || { echo "缺内核"; exit 1; }
cp "$K" "$OUT/kernel.development.fuxi"
cp /root/fuxi/payload-diag.bin "$OUT/payload-diag.bin" 2>/dev/null || true
cp /root/fuxi/fuxi.adt "$OUT/fuxi.adt" 2>/dev/null || true
cp /mnt/e/DSH-Fuxi/fuxi-diag.img "$OUT/boot-current.img" 2>/dev/null || true
sha256sum "$OUT"/kernel.development.fuxi "$OUT"/payload-diag.bin 2>/dev/null | tee "$OUT/SHA256SUMS"
ls -lh "$OUT"
