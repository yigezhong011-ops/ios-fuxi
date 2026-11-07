#!/bin/bash
# Fetch the firmware's required submodules on native storage, then build the firmware.
set -uo pipefail
LOG=/root/firmware-native.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

U=/root/build/uefi-fuxi
cd "$U" || exit 1
echo "--- 现有子模块 ---"
git submodule status 2>/dev/null | cut -c1-90

for m in Common/Mu Common/Mu_OEM_Sample Silicium-ACPI \
         Silicon/Silicium/OpensslPkg/Library/OpensslLib/openssl; do
  if [ -z "$(ls -A "$m" 2>/dev/null)" ]; then
    echo "--- 拉取 $m ---"
    git submodule update --init --depth 1 "$m"
    echo "    exit=$?  内容: $(ls -A "$m" 2>/dev/null | head -3 | tr '\n' ' ')"
  else
    echo "--- $m 已就位 ---"
  fi
done

echo "--- preflight 要求什么 ---"
if [ -f "$U/scripts/check-fuxi.py" ]; then
  python3 "$U/scripts/check-fuxi.py" 2>&1 | tail -15
else
  echo "   (没有 check-fuxi.py)"
fi

echo "--- build firmware ---"
cd /root/build/unixnu || exit 1
./unixnu build firmware -D /root/build/fuxi --uefi "$U" --target DEBUG 2>&1 | tail -25
echo "=== $(date) 结束 ==="
ls -l "$U/Build/fuxiPkg/DEBUG_CLANGPDB/FV/SILICIUM_UEFI.fd" 2>/dev/null
