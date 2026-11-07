#!/bin/bash
# Fork OddlyLabs' fuxi device repository into our account and turn off the optional
# panic-screen patch (it needs the UEFI firmware checkout).
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/fuxi-ours
rm -rf "$W"
git clone -q --depth 1 https://github.com/OddlyLabs/unixnu-fuxi.git "$W"
cd "$W"

echo "=== 当前 panic_screen ==="
grep -n 'panic_screen' board.toml | cut -c1-120

sed -i 's/^panic_screen = true.*$/panic_screen = false                  # the UEFI font is not fetched in CI/' board.toml
grep -n 'panic_screen' board.toml | cut -c1-120

git -c user.name=dsh -c user.email=dsh@local add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "board: skip the optional panic-screen patch (no UEFI checkout in CI)"
git remote add mine "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/fuxi-touch.git"
git push -q -f mine HEAD:main
echo "已推送到 yigezhong011-ops/fuxi-touch"
