#!/bin/bash
# Copy the iOS 16 OS profile from the fuxi port's UniXNU tree into our CI checkout.
set -euo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
W=/root/fuxi/uni-fork
TMP=/root/fuxi/star-unixnu

rm -rf "$TMP"
git clone -q --depth 1 https://github.com/Star-mailaz/fuxi-ios16-unixnu.git "$TMP"
echo "=== 源里的 profile ==="
ls "$TMP/profiles/os/"

cd "$W"
mkdir -p profiles/os
cp -r "$TMP/profiles/os/ios-16.7.16-20H392" profiles/os/
echo "=== 拷入后 ==="
ls profiles/os/
find profiles/os/ios-16.7.16-20H392 -type f | head -8

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "profiles: add the iOS 16.7.16 (20H392) OS profile" 2>/dev/null || echo "（无改动）"
git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/unixnu-ci.git"
git push -q -f ci main
echo "已推送"
