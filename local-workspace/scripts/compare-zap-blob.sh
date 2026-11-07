#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
echo "HEAD 里的 blob: $(git rev-parse HEAD:blobs/a740_zap.mbn)"
echo "本地文件 hash:  $(git hash-object blobs/a740_zap.mbn)"
python3 - <<'PY'
import json
d = json.load(open('scripts/data/fuxi-adreno-inputs.json'))
entry = d['firmware']['files']['qcom/sm8550/fuxi/a740_zap.mbn']
print('pin 里的 sha1:  %s' % entry['git_blob_sha1'])
print('pin 里的仓库:   %s' % entry['repository'])
PY
