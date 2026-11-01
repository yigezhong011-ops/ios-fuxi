#!/bin/bash
# t31-aks1: the third-party touch image with user-boot.img's AppleKeyStore arguments
# (sheng-aks=2 sheng-aks-sls=3 -> sheng-aks=1), to test whether they cause the "Enter Passcode" page.
set -euo pipefail
W=/root/fuxi/t31
export MTOOLS_SKIP_CHECK=1
cp "$W/vol.img" "$W/vol-aks1.img"
mtype -i "$W/vol-aks1.img" ::/EFI/UniXNU/unixnu.toml > "$W/aks1.toml"
python3 - "$W/aks1.toml" <<'PY'
import sys
p = sys.argv[1]
t = open(p).read()
for old, new in ((' sheng-aks=2', ' sheng-aks=1'), (' sheng-aks-sls=3', '')):
    assert t.count(old) == 1, old
    t = t.replace(old, new)
open(p, 'w').write(t)
PY
mcopy -o -i "$W/vol-aks1.img" "$W/aks1.toml" ::/EFI/UniXNU/unixnu.toml
mtype -i "$W/vol-aks1.img" ::/EFI/UniXNU/unixnu.toml | grep -o 'sheng-aks[^ "]*'
bash /root/fuxi/pack-payload.sh "$W/vol-aks1.img" t31-aks1
