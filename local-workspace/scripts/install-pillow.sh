#!/bin/bash
set -uo pipefail
pip install --break-system-packages -q Pillow 2>&1 | tail -3
python3 - <<'PY'
import PIL
print('Pillow', PIL.__version__)
PY
