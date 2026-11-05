#!/bin/bash
# The GPU addon of a CI run in a new volume, without touching gpu-new-t50-mine or t50-mine-gpu-fix.img (install-gpu-addon.sh would overwrite both).
# Same steps as that script: decrypt, fit the addon to the resident size, swap the owner module's CDHashes in the trust cache, write in place.
# Usage: make-t50-plugin.sh <run-id> <work dir>
set -euo pipefail
export MTOOLS_SKIP_CHECK=1
RUN=$1; W=$2; E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; BASE=/root/fuxi/t50-mine
[ ! -e "$W" ] || { echo "refuse to overwrite $W"; exit 1; }
mkdir -p "$W"; cd "$W"
TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
ART=$(curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$RUN/artifacts" | python3 -I -c 'import json,sys; a=json.load(sys.stdin)["artifacts"]; print(next((x["archive_download_url"] for x in a if x["name"] == "fuxi-gpu-encrypted"), ""))')
[ -n "$ART" ]
curl -fsSL -L -H "Authorization: Bearer $TOKEN" "$ART" -o art.zip
unzip -o -q art.zip -d art
F=$(find art -name '*.age' | head -1)
age -d -i $E/keys/fuxi-ci-age.key "$F" > gpu.tar.gz
tar xzf gpu.tar.gz
cat revisions.txt 2>/dev/null | cut -c1-90 || true
ls -l gpuaddon.bin cdhashes.txt | cut -c24-
python3 -I $S/fit-addon.py $BASE/addon-orig.bin gpuaddon.bin addon-fitted.bin
mtype -i $BASE/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache > trust-orig.bin
python3 -I $S/patch-trustcache.py trust-orig.bin cdhashes.txt trust-new.bin
cp $BASE/vol.img vol.img
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon addon-fitted.bin >/dev/null
python3 -I $S/fat-inplace.py vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache trust-new.bin >/dev/null
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon | cmp - addon-fitted.bin
mtype -i vol.img ::/EFI/UniXNU/Payloads/kernel.macho.trustcache | cmp - trust-new.bin
echo "== addon entries against the daily one"
python3 -I - gpuaddon.bin /root/fuxi/gpu-new-t50-mine/gpuaddon.bin <<'EOF'
import struct, sys, zlib, hashlib
def rd(p):
    b = open(p, 'rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24; r = {}
    for _ in range(c):
        nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
        n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
        r[n] = (m, s, hashlib.sha256(zlib.decompress(b[at:at + pk])).hexdigest()[:10]); at += (pk + 7) // 8 * 8
    return r
a, o = rd(sys.argv[1]), rd(sys.argv[2])
for n in sorted(set(a) | set(o)):
    if a.get(n) != o.get(n): print(' ', n, o.get(n), '->', a.get(n))
print('entries', len(o), '->', len(a))
EOF
