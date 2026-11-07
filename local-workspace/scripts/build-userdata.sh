#!/bin/bash
# Build the UniXNU userdata image (SHNGROOT manifest + OS + SystemOS windows) for fuxi from the iPadOS 17.7.11 IPSW, on Linux.
# UniXNU main + ljhhkx529/unixnu-fuxi@old (the t32/t36 board). IPSW and outputs live on E:.
# Usage: build-userdata.sh [download|dry|build]
set -euo pipefail
STEP=${1:-dry}
E=/mnt/e/DSH-Fuxi
IPSW=$E/ipsw/iPad_Pro_HFR_17.7.11_21H461_Restore.ipsw
URL=https://updates.cdn-apple.com/2025SpringFCS/fullrestores/122-77166/DCA6CFE8-90E9-4B92-880D-3DE171798E40/iPad_Pro_HFR_17.7.11_21H461_Restore.ipsw
U=/root/fuxi/ux; D=/root/fuxi/ux-device
mkdir -p $E/ipsw $E/ux-out
if [ "$STEP" = download ]; then
  curl -fL --retry 5 -C - -o "$IPSW" "$URL"
  ls -l "$IPSW"; exit 0
fi
[ -d $U/.git ] || git clone --depth 1 https://github.com/UniXNU/UniXNU.git $U
[ -d $D/.git ] || git clone --depth 1 -b old https://github.com/ljhhkx529/unixnu-fuxi.git $D
command -v lzfse >/dev/null || python3 -c 'import lzfse' 2>/dev/null || apt-get install -y lzfse >/dev/null 2>&1 || true
command -v lzfse || echo "no lzfse binary"
grep -n -A8 '^\[userdata\]' $D/board.toml
cd $U
./unixnu defconfig fuxi_full_defconfig -D $D --out $E/ux-out
if [ "$STEP" = dry ]; then
  ./unixnu build userdata -D $D --out $E/ux-out --ipsw "$IPSW" --dry-run
else
  ./unixnu build userdata -D $D --out $E/ux-out --ipsw "$IPSW"
  find $E/ux-out -name 'userdata-root.*' -printf '%s %p\n'
fi
