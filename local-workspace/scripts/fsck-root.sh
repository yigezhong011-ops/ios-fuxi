#!/bin/bash
set -uo pipefail
R=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/ios16-root-v11.raw
echo "=== 修复 ==="
fsck.hfsplus -f -y "$R" 2>&1 | tail -8
echo "=== 复查 ==="
fsck.hfsplus -n "$R" 2>&1 | tail -3
echo "=== 卷头 ==="
xxd -l 16 -s 1024 "$R"
