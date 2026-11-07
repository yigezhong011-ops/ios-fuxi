#!/bin/bash
set -uo pipefail
F=/root/dev-odd/.github/workflows/build.yml
echo "=== 行数 ==="
wc -l "$F"
echo
echo "=== 关键步骤 ==="
grep -n 'name:\|encrypt\|bootimg\|payload\|firmware\|upload-artifact' "$F" | head -40 | cut -c1-150
