#!/bin/bash
# Read-only: the Wallpaper.plist read error in full, whether wallcat had it, what was packed, and how the addon writes a changed file.
E=/mnt/e/DSH-Fuxi
for n in wallcat wallred; do
  echo "== $n top-level dictionary errors: $(grep -a -c 'did not contain a top-level dictionary' $E/logs/carve-$n/lscan.txt)   FF0000: $(grep -a -c 'FF0000' $E/logs/carve-$n/lscan.txt)"
done
grep -a -m2 'did not contain a top-level dictionary' $E/logs/carve-wallred/lscan.txt | cut -c1-900
grep -a -m4 'FF0000' $E/logs/carve-wallred/lscan.txt | cut -c1-200
cd /root/fuxi/t50-wallred || exit 1
python3 -I - <<'PY'
import plistlib, struct, zlib
b = open('addon-new.bin', 'rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24
for _ in range(c):
    nl, m, s, p = struct.unpack_from('<IIQQ', b, at); at += 24
    n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
    if '5010' in n and n.endswith('Wallpaper.plist'):
        d = zlib.decompress(b[at:at + p]); print(n, 'mode', oct(m), 'size', s, len(d), d[:8])
        v = plistlib.loads(d); print(type(v).__name__, v['assets']['lockAndHome']['dark']['backgroundColors'])
    at += (p + 7) // 8 * 8
PY
O=/root/fuxi/t50-gpu-wall/root/Library/Wallpaper/Collections/Bokeh.wallpaperCollection/Wallpapers/5010.Multicolored.wallpaper/Wallpaper.plist
ls -la "$O" | cut -c20-; head -c 8 "$O" | od -c | head -1
sed -n 125,180p $E/unixnu-build/fuxi/patches/xnu/zzy-native-gpu-addon-mount.patch
D=$(python3 -I $E/unixnu-build/fuxi/scripts/read-sheng-log.py --decode $E/logs/carve-wallred/log.bin --out /root/fuxi/hang/wallred 2>&1 | tail -1 | cut -d: -f1)
echo "== kernel log $D"; sed -n 1p "$D/latest.txt" | cut -c1-80
grep -a -E '^\[gpu clients\]' "$D/latest.txt" | cut -c1-400 | head -2
grep -a -E -i 'addon|WALLPAPER' "$D/latest.txt" | cut -c1-200 | head -8
tail -3 "$D/latest.txt" | cut -c1-200
