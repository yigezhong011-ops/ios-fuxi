#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/mesa-ios/vendor/redwood-drm
mkdir -p "$D"
B=https://raw.githubusercontent.com/iola1999/hackios-xnu-userland/k90-port/tools/mesa/redwood-drm
for f in redwood_drm.c xf86drm.h; do
  curl -sfL -o "$D/$f" "$B/$f" && printf '%-20s %8s B\n' "$f" "$(stat -c%s "$D/$f")"
done
echo "=== redwood_drm.c 里对外暴露的函数 ==="
grep -n '^[a-zA-Z].*(' "$D/redwood_drm.c" | head -25
