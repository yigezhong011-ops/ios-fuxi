#!/bin/bash
set -euo pipefail
IPSW="/mnt/e/DSH-Fuxi/dump/ipsw/iPhone10,3_16.7.16_20H392_Restore.ipsw"
rm -rf /root/fuxi/ipsw
mkdir -p /root/fuxi/ipsw
cd /root/fuxi
ls -lh "$IPSW"
echo "extracting OS + SystemOS + AppOS ..."
unzip -o -q "$IPSW" "087-86698-044.dmg" "087-86593-047.dmg" "087-86715-047.dmg" -d ipsw
ls -lh ipsw/*.dmg
df -h / | tail -1
echo "EXTRACT_OK"
