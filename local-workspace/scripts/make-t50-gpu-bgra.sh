#!/bin/bash
# t50-mine-gpu-fix plus sheng-fb-bgra=1: the plugin then renders every pass in system memory (TU_DEBUG=sysmem,nocb), because the
# tile-memory path comes out with red and blue exchanged (AdrenoMetal 7e0d3d2, NativeAdrenoMetalPlugin.mm:295). Only the toml changes.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; W=/root/fuxi/t50-gpu-bgra
PIN=7e0d3d2ebaecd736784de0baa09254b7f63bc150
echo "== plugin comment"; git -C /root/fuxi/src-adrenometal show $PIN:NativeAdrenoMetalPlugin.mm | sed -n '295,299p' | cut -c1-230
echo "== upstream notes"; git -C /root/fuxi/src-adrenometal log -1 --format='%s%n%b' f72c5d6 | head -12 | cut -c1-220
git -C /root/fuxi/src-adrenometal log -1 --format='%s%n%b' 243d63c | head -8 | cut -c1-220
rm -rf "$W"; mkdir -p "$W"
cp /root/fuxi/gpu-new-t50-mine/vol.img "$W/vol.img"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/toml.orig"
python3 - "$W/toml.orig" "$W/toml" <<'EOF'
import re, sys
t = open(sys.argv[1], encoding='utf-8', newline='').read()
m = re.search(r'args = "([^"]*)"', t)
a = m.group(1)
assert 'sheng-fb-bgra' not in a and 'sheng-tu-debug' not in a
new = a + ' sheng-fb-bgra=1'
print('args length', len(a), '->', len(new))
assert len(new) < 1024, 'XNU boot-args limit'
open(sys.argv[2], 'w', encoding='utf-8', newline='').write(t.replace(a, new))
EOF
python3 -I $E/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/toml" --grow
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml | cmp - "$W/toml"
python3 -I $E/dump/wsl/repack-with-vol.py $E/t50-mine.img "$W/vol.img" $E/t50-mine-gpu-bgra.img
python3 -I $E/dump/wsl/compare-loaders.py $E/t50-mine-gpu-bgra.img
ls -l $E/t50-mine-gpu-bgra.img
cmp -l /root/fuxi/gpu-new-t50-mine/vol.img "$W/vol.img" | wc -l
