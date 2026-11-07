#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== 谁写 original_executable_sha256 / extents 这样的 plan ==="
grep -rln 'original_executable_sha256' "$T/scripts" "$T/kits" 2>/dev/null | head -8
echo
echo "=== 谁写 original_sha256 + extents（plan 结构）==="
grep -rn "'extents'" "$T/scripts" "$T/kits" 2>/dev/null | head -8 | cut -c1-170
echo
echo "=== emit_prelink 是否会写 plan ==="
grep -n 'extents\|original_sha256\|plan' "$T/kits/NativePrelink/emit_prelink.py" 2>/dev/null | head -8 | cut -c1-160
