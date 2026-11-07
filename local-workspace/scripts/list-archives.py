#!/bin/bash
set -uo pipefail
cd /root/fuxi/fork-device || exit 1
git pull -q origin old 2>/dev/null || true
python3 - <<'PY'
import tomllib
from pathlib import Path

board = tomllib.loads(Path('board.toml').read_text())
archives = board.get('kernel', {}).get('archives') or board.get('archives') or []
print('archives 总数: %d' % len(archives))
for i, entry in enumerate(archives, 1):
    print('%2d. %s' % (i, entry[:120]))
PY
