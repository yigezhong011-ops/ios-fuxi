#!/bin/bash
set -uo pipefail
pip install --break-system-packages -q pynacl 2>&1 | tail -2
python3 - <<'PY'
try:
    import nacl
    print('pynacl ok', nacl.__version__)
except Exception as e:
    print('pynacl 不可用:', e)
PY
