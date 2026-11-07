#!/bin/bash
# The panic-screen patch needs a freestanding font header and is optional; turn it
# off so the payload can be produced.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

sed -i 's/^panic_screen = true.*$/panic_screen = false                  # the freestanding font is not shipped here/' board.toml
grep -n 'panic_screen' board.toml | cut -c1-140

git add board.toml
git -c user.name=dsh -c user.email=dsh@local commit -q -m "board: skip the optional panic-screen patch so the payload builds"
git push -q origin old
echo "已推送"
