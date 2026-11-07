#!/bin/bash
set -euo pipefail
IPSW="/mnt/c/Users/USER/Desktop/小米13/dump/ipsw/iPhone10,3_16.7.16_20H392_Restore.ipsw"
ls -lh "$IPSW"
echo "=== dmg / manifest ==="
unzip -l "$IPSW" | grep -iE '\.dmg|BuildManifest' | head -30
echo "=== 全部条目数 ==="
unzip -l "$IPSW" | tail -2
