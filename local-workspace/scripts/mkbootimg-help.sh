#!/bin/bash
set -uo pipefail
python3 /mnt/e/DSH-Fuxi/dump/tools/mkbootimg.py --help 2>&1 | head -40
