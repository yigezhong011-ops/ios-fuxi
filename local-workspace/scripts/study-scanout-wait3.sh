#!/bin/bash
# Read-only study: clone the public GopFramebuffer repo to a new directory, find the wait; locate its writers in t50.
W=/root/fuxi/ref-gopfb
[ -d "$W/.git" ] || timeout 200 git clone -q https://github.com/UniXNU/GopFramebuffer.git "$W" 2>&1 | tail -1
cd "$W" || exit 1
git log -1 --format='HEAD %h %ad %s' --date=short | cut -c1-100
ls | tr '\n' ' '; echo
echo "=== hits"; grep -rnI 'native_gop_wait_stats' . | cut -c1-170 | head -12
F=$(grep -rlI 'native_gop_wait_stats\[' . | head -1); echo "F=$F"
if [ -n "$F" ]; then
  for L in $(grep -n 'native_gop_wait_stats\[' "$F" | cut -d: -f1 | head -1); do sed -n "$((L>60?L-60:1)),$((L+22))p" "$F" | cut -c1-160; done
  echo "=== history"; git log --format='%h %ad %s' --date=short -8 -- "$F" | cut -c1-100
fi
echo "=== prepare report"; grep -rnI 'native_legacy_prepare_report' . | cut -c1-140 | head -4
G=$(grep -rlI 'native_legacy_prepare_report' . | head -1); [ -n "$G" ] && L=$(grep -n 'native_legacy_prepare_report' "$G" | head -1 | cut -d: -f1) && sed -n "$L,$((L+14))p" "$G" | cut -c1-190
echo "=== t50"
K=/root/fuxi/t50/kernel.macho
A=$(llvm-nm $K | awk '$3=="_native_gop_wait_stats"{print $1}'); echo "stats at $A"
[ -n "$A" ] && python3 -I /mnt/e/DSH-Fuxi/dump/wsl/find-coh-readers.py $K $A | cut -c1-110 | head -14
llvm-nm $K | grep -E ' _native_(legacy|gop)_.*(wait|Wait|vsync|vbl)' | cut -c18-90 | head
