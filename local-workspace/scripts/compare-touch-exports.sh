#!/bin/bash
# Compare the extern "C" interface of our Novatek TouchProbe.cpp with OddlyLabs' FuxiTouchProbe.cpp,
# and list which native_touch_* / touch symbols the rest of our package uses.
set -euo pipefail
OURS=/root/fuxi/fork-device/package/TouchProbe.cpp
FTS=/root/fuxi/fuxi-ours/package/FuxiTouchProbe.cpp
ext() { grep -o -E 'extern "C" [^(]*\b([a-z_][a-z0-9_]*)\s*\(' "$1" | sed -E 's/.*\b([a-z_][a-z0-9_]*)\s*\($/\1/' | sort -u; }
echo "== exported by ours";  ext "$OURS"
echo "== exported by FTS";   ext "$FTS"
echo "== only in ours";      comm -23 <(ext "$OURS") <(ext "$FTS")
echo "== users in our package/drivers (outside TouchProbe.cpp)"
grep -rn -o -E '\bnative_touch_[a-z_]+|\bsheng_touch_[a-z_]+' /root/fuxi/fork-device/package /root/fuxi/fork-device/patches \
  | grep -v 'TouchProbe.cpp' | sed -E 's/:[0-9]+:/ /' | sort -u
