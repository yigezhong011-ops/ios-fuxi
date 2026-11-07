#!/bin/bash
set -uo pipefail
P=$HOME/.local/xnu-linux
echo "=== $P/bin ==="
ls "$P/bin" 2>/dev/null | head -25
echo
echo "=== $P/cctools ==="
ls "$P/cctools" 2>/dev/null | head -8
echo
echo "=== 关键工具 ==="
for t in host-clang target-clang iig plutil xcrun ld ld64 mig migcom unifdef lzfse tcsh; do
  if [ -e "$P/bin/$t" ]; then printf '  %-12s ✓\n' "$t"; else printf '  %-12s ✗\n' "$t"; fi
done
