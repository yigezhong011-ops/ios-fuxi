#!/bin/bash
# Make a temp-boot variant of a third-party image volume with edited boot arguments.
# Usage: make-arg-variant.sh <vol.img> <out-name> <edit>...   edit: rm:ARG | add:ARG | key=value (replace that key)
# KERNEL=<file> replaces Payloads/kernel.macho, ADT=<file> Payloads/kernel.macho.adt, GPUADDON=<file> Payloads/kernel.macho.gpuaddon.
#
# Every file is overwritten in place, over its own clusters, at exactly its old size (fat-inplace.py); unixnu.toml is padded with
# spaces to its old length. The payload keeps its packed Data seed in clusters FAT calls free (payload.adt packed_data_ramdisk; the
# loader fills /chosen/memory-map/PackedRAMDisk): mtools' mcopy -o reallocates chains, which moved the kernel and the ADT and
# overwrote 41 MiB of the seed, and zeroing the free space erased it. Images with sheng-data-persist=2 still booted from the
# stored Data; every fresh-Data image stopped at the colour bars or the Mi logo.
set -euo pipefail
VOL=$1; OUT=$2; shift 2
W=/root/fuxi/variant-$OUT
rm -rf "$W"; mkdir -p "$W"
export MTOOLS_SKIP_CHECK=1
cp "$VOL" "$W/vol.img"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/unixnu.toml.orig"
cp "$W/unixnu.toml.orig" "$W/unixnu.toml"
python3 - "$W/unixnu.toml" "$@" <<'PY'
import os, re, sys
p, edits = sys.argv[1], sys.argv[2:]
old = open(p, 'rb').read()
t = old.decode()
m = re.search(r'args = "([^"]*)"', t)
args = m.group(1).split()
for e in edits:
    if e.startswith('rm:'):
        assert e[3:] in args, e
        args.remove(e[3:])
    elif e.startswith('add:'):
        args.append(e[4:])
    else:
        key = e.split('=')[0]
        hits = [i for i, a in enumerate(args) if a.split('=')[0] == key]
        assert len(hits) == 1, e
        args[hits[0]] = e
t = t[:m.start()] + 'args = "' + ' '.join(args) + '"' + t[m.end():]
new = t.encode()
if len(new) > len(old):
    sys.exit(f'unixnu.toml grows by {len(new) - len(old)} bytes: cannot stay in place')
new = new.rstrip(b'\n') + b'\n' + b' ' * (len(old) - len(new.rstrip(b'\n')) - 1)   # same length, trailing spaces
assert len(new) == len(old)
open(p, 'wb').write(new)
print('args:', ' '.join(args))
PY
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/unixnu.toml "$W/unixnu.toml"
[ -n "${KERNEL:-}" ] && python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho "$KERNEL" \
  && echo "kernel replaced with $KERNEL"
[ -n "${ADT:-}" ] && python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.adt "$ADT" \
  && echo "ADT replaced with $ADT"
[ -n "${GPUADDON:-}" ] && python3 -I /mnt/e/DSH-Fuxi/dump/wsl/fat-inplace.py "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon "$GPUADDON" \
  && echo "gpuaddon replaced with $GPUADDON"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml | cmp -s - "$W/unixnu.toml" || { echo "toml read back mismatch"; exit 1; }
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/diff-variant-vol.py "$VOL" "$W/vol.img" | head -1 | sed 's/^/volume: /'
bash /root/fuxi/pack-payload.sh "$W/vol.img" "$OUT" | tail -2
