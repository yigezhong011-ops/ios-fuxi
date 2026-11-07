#!/bin/bash
set -uo pipefail
cd /root/UniXNU
python3 ./unixnu build firmware --uefi /root/uefi-fuxi -D /root/UniXNU-fuxi > /root/unixnu-fw4.log 2>&1
echo "FW4_EXIT=$?"
echo "=== 结果 ==="
grep -E 'firmware: |ERROR|GenFv' /root/unixnu-fw4.log | tail -8
ls -lh /root/uefi-fuxi/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd
