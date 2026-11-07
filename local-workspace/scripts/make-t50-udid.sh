#!/bin/bash
# t50-auto-g7f9u: t50-auto-g7f9 with udid-version=2 in the ADT, for the cold Settings test. Temp boot only; writes no partition.
# The image's toml and kernel do not change; the ADT file grows inside its own last cluster.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; T=/root/fuxi/tap-t50-auto-g7f9; W=/root/fuxi/t50-g7f9u; OUT=t50-auto-g7f9u
A=::/EFI/UniXNU/Payloads/kernel.macho.adt
rm -rf "$W"; mkdir -p "$W"; cd "$W"
cp "$T/vol.img" vol.img; cp "$T/kernel.macho" kernel.macho
mtype -i vol.img $A > adt.old
python3 -I $S/patch-adt-udid.py adt.old adt.new
grep -n 'grow' $S/fat-inplace.py | head -3 | cut -c1-100
python3 -I $S/fat-inplace.py vol.img $A adt.new --grow >/dev/null
mtype -i vol.img $A | cmp - adt.new
mtype -i vol.img ::/EFI/UniXNU/unixnu.toml | grep -c -iE 'adt.*(sha|hash)' || true
tr -d '\r' < $S/make-t50-auto.sh > /tmp/make-t50-auto-u.sh
bash /tmp/make-t50-auto-u.sh "$W" 420 "$OUT" 2>&1 | tail -3
ls -la $E/$OUT.img
