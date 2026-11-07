#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/mesa-ios/userland
mkdir -p "$D"
B=https://raw.githubusercontent.com/iola1999/hackios-xnu-userland/k90-port/userland
for f in mkeagl.py src/eagl.c src/eagl_slots.txt src/gl_osmesa.c; do
  out="$D/$(basename "$f")"
  if curl -sfL -o "$out" "$B/$f"; then
    printf '%-16s %8s B\n' "$(basename "$f")" "$(stat -c%s "$out")"
  else
    echo "MISS $f"
  fi
done
echo "=== eagl_slots.txt 前几行 ==="
head -6 "$D/eagl_slots.txt"
echo "=== gl_osmesa.c 头部 ==="
head -20 "$D/gl_osmesa.c"
