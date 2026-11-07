#!/bin/bash
# Compare the fence statistics of the mailbox variant against the baseline.
set -uo pipefail
DIR=${1:-/root/fuxi/cad-mb1/untagged-339f52412}
echo "=== 目录 $DIR ==="
echo
echo "=== [fence wait]（最后 2 条）==="
grep -a '^\[fence wait\] calls' "$DIR/slots.txt" | tail -2 | cut -c1-220
echo
echo "=== [coherence]（最后 2 条）==="
grep -a '^\[coherence\] H' "$DIR/slots.txt" | tail -2 | cut -c1-230
echo
echo "=== 帧间隔（slots 的 W 行）==="
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/read-cadence.py "$DIR" 2>&1 | head -6
