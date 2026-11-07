#!/bin/bash
set -uo pipefail
B=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
echo "=== building.md 里 runner / workflow 的提到 ==="
grep -n -i 'runner' "$B/docs/building.md" | head -10
echo
echo "=== .github/workflows 里的文件 ==="
ls -1 "$B/.github/workflows" 2>/dev/null
echo
echo "=== 找 macos build workflow ==="
for f in "$B"/.github/workflows/*; do
  [ -f "$f" ] || continue
  if grep -qi 'macos' "$f" 2>/dev/null; then echo "  $(basename "$f")"; fi
done
