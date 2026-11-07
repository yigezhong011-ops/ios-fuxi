#!/bin/bash
set -euo pipefail
IPSW="/mnt/c/Users/USER/Desktop/小米13/dump/ipsw/iPhone10,3_16.7.16_20H392_Restore.ipsw"
mkdir -p /root/fuxi/ipsw
cd /root/fuxi
echo "extracting OS + SystemOS + AppOS dmgs..."
unzip -o -q "$IPSW" "087-86698-044.dmg" "087-86593-047.dmg" "087-86715-047.dmg" -d ipsw
ls -lh ipsw/*.dmg
echo "done"
