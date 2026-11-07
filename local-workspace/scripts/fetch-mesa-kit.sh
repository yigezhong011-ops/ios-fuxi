#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/mesa-ios/vendor
mkdir -p "$D/patches" "$D/redwood-drm"
B=https://raw.githubusercontent.com/iola1999/hackios-xnu-userland/k90-port/tools/mesa
for f in freedreno-darwin.patch osmesa-es-profile.patch ir3-round-default.patch ir3-shift-split.patch ir3-ssbo-subdword.patch; do
  curl -sfL -o "$D/patches/$f" "$B/$f" && printf '%-32s %8s B\n' "$f" "$(stat -c%s "$D/patches/$f")" || echo "MISS $f"
done
echo "=== redwood-drm 目录文件 ==="
curl -sfL "https://api.github.com/repos/iola1999/hackios-xnu-userland/contents/tools/mesa/redwood-drm?ref=k90-port" \
  | python3 -c 'import json,sys; [print(x["name"], x["size"]) for x in json.load(sys.stdin)]' 2>/dev/null | head -20
