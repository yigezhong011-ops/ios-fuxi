#!/bin/bash
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old
cp /tmp/stubgen5/libFuxiLinkStubs.a package/libFuxiLinkStubs.a
ls -l package/libFuxiLinkStubs.a
git add -f package/libFuxiLinkStubs.a
git -c user.name=dsh -c user.email=dsh@local commit -q -m "package: keep only the symbols nothing else provides"
git push -q origin old
echo "已推送"
git log --oneline -1
