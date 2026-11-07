#!/bin/bash
# Downloads and decrypts a CI run's GPU addon into a new directory. Nothing else. Usage: get-ci-plugin.sh <run-id> <dir>
set -euo pipefail
RUN=$1; W=$2; E=/mnt/e/DSH-Fuxi
[ ! -e "$W" ] || { echo "refuse to overwrite $W"; exit 1; }
mkdir -p "$W"; cd "$W"
TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
ART=$(curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/runs/$RUN/artifacts" | python3 -I -c 'import json,sys; a=json.load(sys.stdin)["artifacts"]; print(next((x["archive_download_url"] for x in a if x["name"] == "fuxi-gpu-encrypted"), ""))')
[ -n "$ART" ]
curl -fsSL -L -H "Authorization: Bearer $TOKEN" "$ART" -o art.zip
unzip -o -q art.zip -d art
age -d -i $E/keys/fuxi-ci-age.key "$(find art -name '*.age' | head -1)" > gpu.tar.gz
tar xzf gpu.tar.gz
cat revisions.txt 2>/dev/null | cut -c1-90 || true
ls -l | cut -c24- | head -20
python3 -I - gpuaddon.bin /root/fuxi/gpu-plugin-1105/gpuaddon.bin <<'EOF'
import struct, sys, zlib, hashlib
def rd(p):
    b = open(p, 'rb').read(); c = struct.unpack_from('<I', b, 8)[0]; at = 24; r = {}
    for _ in range(c):
        nl, m, s, pk = struct.unpack_from('<IIQQ', b, at); at += 24
        n = b[at:at + nl - 1].decode(); at += (nl + 7) // 8 * 8
        r[n] = (m, s, pk, hashlib.sha256(zlib.decompress(b[at:at + pk])).hexdigest()[:10]); at += (pk + 7) // 8 * 8
    return r
a, o = rd(sys.argv[1]), rd(sys.argv[2])
for n in sorted(set(a) | set(o)):
    if a.get(n) != o.get(n): print(' ', n, o.get(n), '->', a.get(n))
print('entries', len(o), '->', len(a), 'packed', sum(v[2] for v in o.values()), '->', sum(v[2] for v in a.values()))
EOF
