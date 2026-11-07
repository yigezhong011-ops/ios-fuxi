#!/bin/bash
# Two comparison images from patch-t50-gpu7.py, temp boot only, no partition written.
#   t50-auto-gpu7a: gpu7 plus three more poster processes in the grant.
#   t50-auto-gpu7b: the 3 GiB aperture alone: slot choice, windows and grant as in t50-shot.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; B=/root/fuxi/t50-shot; AP=0xfffffff00c00c3cc
tr -d '\r' < $S/patch-t50-gpu7.py > /tmp/p7.py
# Variant a: longer list.
sed "s/,AegirPoster,WeatherPoster,PhotosPosterProvider/,AegirPoster,WeatherPoster,PhotosPosterProvider,KaleidoscopePoster,PridePosterExtension,HelloPosterExtension/" /tmp/p7.py > /tmp/p7a.py
grep -c KaleidoscopePoster /tmp/p7a.py
# Variant b: keep only the aperture section and the file output.
python3 -I - <<'PY'
s = open('/tmp/p7.py').read()
a = s.index('# --- slot choice'); b = s.index('# --- 3 GiB aperture')
open('/tmp/p7b.py', 'w').write(s[:a] + s[b:])
PY
for v in a b; do
  W=/root/fuxi/t50-gpu7$v; rm -rf "$W"; mkdir -p "$W"; cp "$B/vol.img" "$W/vol.img"
  python3 -I /tmp/p7$v.py "$B/kernel.macho" "$W/kernel.macho" "$AP"
  python3 -I $S/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.macho" >/dev/null
  mcopy -n -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$W/kernel.back"; cmp "$W/kernel.back" "$W/kernel.macho"
  echo "gpu7$v kernel bytes changed: $(cmp -l "$B/kernel.macho" "$W/kernel.macho" | wc -l)"
  llvm-objdump -d --no-show-raw-insn --start-address=0xfffffff00c00ec9c --stop-address=0xfffffff00c00eca0 "$W/kernel.macho" | tail -1 | cut -c1-60
  llvm-objdump -d --no-show-raw-insn --start-address=$AP --stop-address=0xfffffff00c00c3d0 "$W/kernel.macho" | tail -1 | cut -c1-70
  tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto.sh
  bash /tmp/make-t50-auto.sh "$W" 420 t50-auto-gpu7$v | tail -1
done
strings -a /root/fuxi/t50-gpu7a/kernel.macho | grep -a 'backboardd,icon' | cut -c1-140
