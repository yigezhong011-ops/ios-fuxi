#!/bin/bash
set -uo pipefail
pip install --break-system-packages -q opencv-python-headless numpy 2>&1 | tail -2
python3 - <<'PY'
import cv2
print('opencv', cv2.__version__)
PY
python3 /mnt/e/DSH-Fuxi/dump/wsl/decode-qr-log.py \
  "/mnt/c/Users/USER/.dsh/attachments/v1/objects/ab/abecdaf40a5d0735173606a9866f9999144dc2923eb3ce06731cf968bb43a087" 2>&1 | head -30
