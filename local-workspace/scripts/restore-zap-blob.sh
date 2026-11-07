#!/bin/bash
# The ZAP blob exists on disk but was never in HEAD (a reset dropped it), so the
# firmware fetch 404s. Commit it and verify the blob is reachable.
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git checkout -q old && git pull -q origin old

mkdir -p blobs
cp /mnt/c/Users/USER/Downloads/a740_zap-odm.mbn blobs/a740_zap.mbn
git add -f blobs/a740_zap.mbn
git -c user.name=dsh -c user.email=dsh@local commit -qm "blobs: add the board's signed a740_zap.mbn"
git push -q origin old
echo "已推送"
echo "HEAD 里的 blob: $(git rev-parse HEAD:blobs/a740_zap.mbn)"

python3 - <<'PY'
import hashlib, json
from pathlib import Path
b = Path('blobs/a740_zap.mbn').read_bytes()
d = json.loads(Path('scripts/data/fuxi-adreno-inputs.json').read_text())
e = d['firmware']['files']['qcom/sm8550/fuxi/a740_zap.mbn']
print('文件 %d B  sha256 %s' % (len(b), hashlib.sha256(b).hexdigest()[:24]))
print('pin  bytes %s  sha256 %s' % (e['bytes'], e['sha256'][:24]))
print('pin  sha1 %s' % e['git_blob_sha1'])
PY
