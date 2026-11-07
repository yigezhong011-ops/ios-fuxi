#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/mesa-ios/userland
B=https://raw.githubusercontent.com/iola1999/hackios-xnu-userland/k90-port/userland/src
for f in redwood_gl.h redwood.h; do
  if curl -sfL -o "$D/$f" "$B/$f"; then
    printf '%-16s %8s B\n' "$f" "$(stat -c%s "$D/$f")"
  else
    echo "MISS $f"
  fi
done
echo "=== redwood_gl.h 内容（前 40 行）==="
head -40 "$D/redwood_gl.h" 2>/dev/null
