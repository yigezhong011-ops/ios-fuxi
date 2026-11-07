#!/bin/bash
# Build a fresh iPhone X (D22AP) iOS 16.7.11 root image from the downloaded IPSW.
set -euo pipefail
IPSW=${1:-/mnt/e/DSH-Fuxi/dump/iphonex-16.7.11.ipsw}
WORK=/root/fuxi/build-x
mkdir -p "$WORK"
cd "$WORK"

echo "=== IPSW 内容概览 ==="
unzip -l "$IPSW" | grep -E '\.dmg|DeviceTree.d22ap' | head -20
