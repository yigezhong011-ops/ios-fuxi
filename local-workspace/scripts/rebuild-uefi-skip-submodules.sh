#!/bin/bash
# Stop git from re-fetching the submodules that are already populated, then rebuild.
set -uo pipefail
U=/mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi
cd "$U" || exit 1

echo "=== 各子模块是否已就位 ==="
for m in Binaries Common/Mu Common/Mu_OEM_Sample Mu_Basecore Silicium-ACPI \
         Silicon/Silicium/OpensslPkg/Library/OpensslLib/openssl; do
  if [ -d "$m" ] && [ -n "$(ls -A "$m" 2>/dev/null)" ]; then
    git config "submodule.$m.update" none
    printf '  %-58s 已就位，已设为 none\n' "$m"
  else
    printf '  %-58s 缺失\n' "$m"
  fi
done

LOG=/root/uefi-build.log
: > "$LOG"
echo "=== $(date) 重新构建（跳过已就位子模块）===" | tee -a "$LOG"
python3 build_uefi.py -d fuxi -r DEBUG >>"$LOG" 2>&1
echo "=== $(date) 结束 exit=$? ===" | tee -a "$LOG"
tail -25 "$LOG"
