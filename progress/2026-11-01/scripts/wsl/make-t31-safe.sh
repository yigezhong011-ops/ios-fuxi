#!/bin/bash
# t31-safe: the third-party touch image with sheng-log=1 and sheng-data-persist=2 removed from its boot arguments
# (both write windows at the end of userdata; suspected in the slot a damage). Only unixnu.toml changes.
set -euo pipefail
W=/root/fuxi/t31
export MTOOLS_SKIP_CHECK=1
cp "$W/vol.img" "$W/vol-safe.img"
mtype -i "$W/vol-safe.img" ::/EFI/UniXNU/unixnu.toml > "$W/safe.toml"
python3 - "$W/safe.toml" <<'PY'
import sys
p = sys.argv[1]
t = open(p).read()
for a in (' sheng-log=1', ' sheng-data-persist=2'):
    assert t.count(a) == 1, a
    t = t.replace(a, '')
open(p, 'w').write(t)
PY
mcopy -o -i "$W/vol-safe.img" "$W/safe.toml" ::/EFI/UniXNU/unixnu.toml
mtype -i "$W/vol-safe.img" ::/EFI/UniXNU/unixnu.toml | grep -c -E 'sheng-log|sheng-data-persist' || echo "storage args removed"
mdir -i "$W/vol-safe.img" ::/EFI/UniXNU/Payloads | grep -i kernel
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/pack-payload.sh > /root/fuxi/pack-payload.sh
bash /root/fuxi/pack-payload.sh "$W/vol-safe.img" t31-safe
