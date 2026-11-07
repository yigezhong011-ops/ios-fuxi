#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
echo "=== 提到 root_match_volume_uuid 的文档 ==="
grep -rln 'root_match_volume_uuid' "$D" 2>/dev/null | head -6
echo
echo "=== 相关段落 ==="
grep -rn -A6 -B2 'root_match_volume_uuid' "$D"/guide/*.md "$D"/reference/*.md "$D"/porting/*.md 2>/dev/null | head -40
