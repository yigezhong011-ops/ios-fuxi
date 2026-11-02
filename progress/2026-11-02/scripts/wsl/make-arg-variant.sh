#!/bin/bash
# Make a temp-boot variant of a third-party image volume with edited boot arguments.
# Usage: make-arg-variant.sh <vol.img> <out-name> <edit>...   edit: rm:ARG | add:ARG | key=value (replace that key)
# ADT=<file> in the environment also replaces Payloads/kernel.macho.adt; KERNEL=<file> replaces Payloads/kernel.macho
# (same size only: an in-place copy of a different size corrupts the FAT bookkeeping, see build-fts2.sh).
set -euo pipefail
VOL=$1; OUT=$2; shift 2
W=/root/fuxi/variant-$OUT
rm -rf "$W"; mkdir -p "$W"
export MTOOLS_SKIP_CHECK=1
cp "$VOL" "$W/vol.img"
mtype -i "$W/vol.img" ::/EFI/UniXNU/unixnu.toml > "$W/unixnu.toml"
python3 - "$W/unixnu.toml" "$@" <<'PY'
import re, sys
p, edits = sys.argv[1], sys.argv[2:]
t = open(p).read()
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
open(p, 'w').write(t)
print('args:', ' '.join(args))
PY
mcopy -o -i "$W/vol.img" "$W/unixnu.toml" ::/EFI/UniXNU/unixnu.toml
if [ -n "${KERNEL:-}" ]; then
  old=$(mdir -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho | awk '/kernel.macho/{gsub(/ /,"",$3); print $3}' | tr -d ' ')
  new=$(stat -c %s "$KERNEL")
  mcopy -o -i "$W/vol.img" "$KERNEL" ::/EFI/UniXNU/Payloads/kernel.macho
  mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho | cmp -s - "$KERNEL" || { echo "kernel copy mismatch"; exit 1; }
  echo "kernel replaced with $KERNEL ($new bytes), read back identical"
fi
if [ -n "${ADT:-}" ]; then
  mcopy -o -i "$W/vol.img" "$ADT" ::/EFI/UniXNU/Payloads/kernel.macho.adt
  echo "ADT replaced with $ADT"
fi
# GPUADDON=<file> replaces Payloads/kernel.macho.gpuaddon, same size only (addon-set-clients.py --same-size), written over its
# own clusters like KERNEL.
# Never allocate new clusters or clear the free ones: the Data seed is packed into the FAT's free space (payload.adt
# packed_data_ramdisk; the loader fills /chosen/memory-map/PackedRAMDisk). Zeroing it (6.5 MiB less gzip) made every such
# image stop at the Mi logo or go black after the colour bars (t32-bl-daily-z vs the identical t32-bl-daily).
if [ -n "${GPUADDON:-}" ]; then
  old=$(mdir -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | awk '/gpuaddon/{print $3}' | tr -d ' ')
  new=$(stat -c %s "$GPUADDON")
  [ "$old" = "$new" ] || { echo "gpuaddon size $new != $old: refusing"; exit 1; }
  mcopy -o -i "$W/vol.img" "$GPUADDON" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon
  mtype -i "$W/vol.img" ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp -s - "$GPUADDON" || { echo "gpuaddon copy mismatch"; exit 1; }
  echo "gpuaddon replaced with $GPUADDON ($new bytes), read back identical"
fi
# Nothing outside the replaced files may change: count differing bytes against the source volume.
echo "volume bytes changed: $(cmp -l "$VOL" "$W/vol.img" | wc -l)"
bash /root/fuxi/pack-payload.sh "$W/vol.img" "$OUT" | tail -2
