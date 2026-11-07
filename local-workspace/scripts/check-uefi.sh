#!/bin/bash
set -uo pipefail
cd /root/uefi-fuxi
echo "=== Platforms/Xiaomi ==="
ls Platforms/Xiaomi/ 2>/dev/null || echo "(无)"
echo "=== pytool ==="
python3 -c 'import edk2toolext; print("pytool ok", edk2toolext.__version__ if hasattr(edk2toolext,"__version__") else "")' 2>&1
echo "=== build_uefi.py help ==="
python3 build_uefi.py --help 2>&1 | head -25
