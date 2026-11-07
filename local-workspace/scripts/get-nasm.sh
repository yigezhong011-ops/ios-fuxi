#!/bin/bash
set -uo pipefail
python3 - <<'PY'
import json, subprocess, pathlib
idx = json.loads(pathlib.Path('/root/mu-index.json').read_text())
base = None
for r in idx['resources']:
    if 'PackageBaseAddress' in r.get('@type',''):
        base = r['@id'].rstrip('/')
        break
print('PackageBaseAddress:', base)
if base:
    url = f"{base}/mu_nasm/20016.1.1/mu_nasm.20016.1.1.nupkg"
    print('url:', url)
    pathlib.Path('/root/mu_url.txt').write_text(url)
PY
URL=$(cat /root/mu_url.txt)
mkdir -p /root/local-feed
curl -fsSL --retry 2 "$URL" -o /root/local-feed/mu_nasm.20016.1.1.nupkg && ls -lh /root/local-feed/ || echo "DOWNLOAD_FAIL"
