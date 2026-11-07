#!/bin/bash
set -uo pipefail
DEV=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
echo "=== 当前 panic_screen ==="
grep -n 'panic_screen' "$DEV/board.toml" | head -3
sed -i 's/^panic_screen = true.*$/panic_screen = false                     # t32'"'"'s kernel has a different entry sequence/' "$DEV/board.toml"
grep -n 'panic_screen' "$DEV/board.toml" | head -3
bash /root/fuxi/rs2.sh >/dev/null 2>&1
tail -14 /root/rebuild-payload.log
