#!/bin/bash
# Build OddlyLabs' fuxi port: their UniXNU fork carries the FuxiFtsTouch component.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/uni-oddly
rm -rf "$W"
git clone -q --depth 1 https://github.com/OddlyLabs/UniXNU.git "$W"
cd "$W"
echo "=== 他们的 UniXNU ==="
git log --oneline -1 | cut -c1-100
echo "=== components.toml 里有没有 FuxiFtsTouch ==="
grep -c 'FuxiFtsTouch' components.toml 2>/dev/null || echo 0
grep -n -A3 'FuxiFtsTouch' components.toml 2>/dev/null | head -8 | cut -c1-140
echo "=== OS profile ==="
ls profiles/os/ 2>/dev/null | head -6
echo "=== defconfigs of their device repo ==="
