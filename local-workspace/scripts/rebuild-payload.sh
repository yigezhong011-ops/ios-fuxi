#!/bin/bash
set -uo pipefail
ls -l /root/fuxi/ 2>/dev/null | head -12
echo "=== 重建 payload ==="
cd /root/ios-fuxi
K=/mnt/e/DSH-Fuxi/ci/kernel-kick/kernel.development.fuxi
ls -l "$K" 2>/dev/null || echo "(kernel missing)"
ADT=/root/fuxi/fuxi.adt
ls -l "$ADT" 2>/dev/null || echo "(adt missing)"
CMDLINE=$(grep '^CMDLINE=' /mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh | sed 's/^CMDLINE="//; s/"$//')
if [ -f "$K" ] && [ -f "$ADT" ]; then
  python3 tools/mkpayload.py "$K" "$ADT" /root/fuxi/payload-diag.bin --cmdline "$CMDLINE" 2>&1 | tail -2
  ls -lh /root/fuxi/payload-diag.bin
fi
