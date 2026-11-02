#!/bin/bash
# Accept t32's trust cache in the local device repository copy, then rebuild the payload.
set -uo pipefail
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
TC=/root/rebuild/trustcache
SHA=$(sha256sum "$TC" | cut -d' ' -f1)
echo "t32 trust cache sha256: $SHA"

python3 - "$DEV/board.toml" "$SHA" <<'PY'
import sys, re
from pathlib import Path
p, sha = Path(sys.argv[1]), sys.argv[2]
text = p.read_text()
if sha in text:
    print('已经在白名单里')
    sys.exit()
m = re.search(r'trust_cache_sha256\s*=\s*\[(.*?)\]', text, re.S)
if not m:
    sys.exit('board.toml 里没有 trust_cache_sha256')
block = m.group(0)
new = block.replace(']', '  "%s",\n]' % sha)
p.write_text(text.replace(block, new, 1))
print('已加入白名单')
print(new)
PY

grep -A6 'trust_cache_sha256' "$DEV/board.toml" | head -8
