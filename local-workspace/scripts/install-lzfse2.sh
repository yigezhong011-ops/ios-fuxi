#!/bin/bash
set -uo pipefail
pip install --quiet --break-system-packages lzfse 2>&1 | tail -2
python3 - <<'PY'
try:
    import lzfse
    print('lzfse module OK')
except Exception as e:
    print('lzfse missing:', e)
PY
