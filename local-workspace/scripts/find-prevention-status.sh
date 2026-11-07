#!/bin/bash
set -uo pipefail
T=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree
echo "=== 全树搜 prevention-status ==="
grep -rIn 'prevention-status\|prevention_status' "$T" 2>/dev/null | head -12
echo
echo "=== 搜 mix_n_match / mix-n-match（含 kits/drivers）==="
grep -rIn 'mix_n_match\|mix-n-match' "$T/drivers" "$T/kits" "$T/package" 2>/dev/null | head -12
echo
echo "=== 搜 boot arg 里可能的名字 ==="
grep -rIn 'mix.*match' "$T/build" 2>/dev/null | head -8
