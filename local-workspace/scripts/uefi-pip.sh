#!/bin/bash
set -uo pipefail
python3 -m pip install --break-system-packages --ignore-installed rich \
  'edk2-pytool-library~=0.23.17' 'edk2-pytool-extensions~=0.31.2' > /root/uefi-pip2.log 2>&1
echo "PIP2_EXIT=$?"
tail -3 /root/uefi-pip2.log
python3 -c 'import edk2toolext; print("pytool OK")' 2>&1 | tail -2
