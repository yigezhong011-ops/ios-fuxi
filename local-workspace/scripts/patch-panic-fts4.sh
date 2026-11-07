#!/bin/bash
# Patch the entry probe + panic screen into a copy of the OddlyLabs touch kernel
# (our CI build had panic_screen=false).
# Usage: patch-panic-fts4.sh [out-dir [probe args...]]
#   default: /root/fuxi/pkg-fts4 --panic-screen --no-reset
#   e.g.     /root/fuxi/pkg-fts5 --reset-delay 6     (docs/zh/guide/debugging.md "入口探针复位")
#   The panic screen and a reset probe do not both fit in the padding after _start.
set -euo pipefail
for t in clang ld.lld llvm-objcopy llvm-nm llvm-size llvm-readelf; do
  printf '%s: ' "$t"; command -v "$t" || echo MISSING
done
W=${1:-/root/fuxi/pkg-fts4}
shift || true
PROBE=("$@")
[ ${#PROBE[@]} -eq 0 ] && PROBE=(--panic-screen --no-reset)
mkdir -p "$W"
cp /root/fuxi/touch-kernel.macho "$W/kernel.macho"
cd /root/fuxi/uni-oddly-fuxi
UNIXNU_UEFI=/root/fuxi/fork-device/uefi-fonts python3 scripts/patch-xnu-entry-probe.py "$W/kernel.macho" "${PROBE[@]}"
if cmp -s /root/fuxi/touch-kernel.macho "$W/kernel.macho"; then echo "kernel unchanged"; exit 1; fi
echo "kernel patched"
