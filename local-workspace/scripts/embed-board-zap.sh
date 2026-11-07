#!/bin/bash
# Put the board's own signed ZAP into our device fork and point the firmware pin
# at it, so the kernel embeds fuxi's copy instead of the tablet's.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/fork-device
ZAP=/mnt/c/Users/USER/Downloads/a740_zap-odm.mbn

cd "$W"
git fetch -q origin old && git reset -q --hard origin/old

mkdir -p blobs
cp "$ZAP" blobs/a740_zap.mbn
python3 - <<'PY'
import hashlib, json
from pathlib import Path

zap = Path('blobs/a740_zap.mbn').read_bytes()
sha256 = hashlib.sha256(zap).hexdigest()
blob_sha1 = hashlib.sha1(b'blob %d\0' % len(zap) + zap).hexdigest()

pins = Path('scripts/data/fuxi-adreno-inputs.json')
d = json.loads(pins.read_text())
entry = d['firmware']['files']['qcom/sm8550/fuxi/a740_zap.mbn']
print('原 pin:', entry['bytes'], entry['sha256'][:16])
entry['repository'] = 'https://github.com/yigezhong011-ops/unixnu-fuxi'
entry['git_blob_sha1'] = blob_sha1
entry['bytes'] = len(zap)
entry['sha256'] = sha256
pins.write_text(json.dumps(d, indent=2) + '\n')
print('新 pin:', len(zap), sha256[:16], blob_sha1[:12])
PY

git -c user.name=dsh -c user.email=dsh@local add -A
git -c user.name=dsh -c user.email=dsh@local commit -q -m "firmware: embed the board's own signed a740_zap.mbn"
git push -q origin old
echo "已推送"
python3 -c "import json;d=json.load(open('scripts/data/fuxi-adreno-inputs.json'));print(json.dumps(d['firmware']['files']['qcom/sm8550/fuxi/a740_zap.mbn'],indent=2))"
