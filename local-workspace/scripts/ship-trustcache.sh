#!/bin/bash
# Ship the pinned trust-cache bundle so the payload step can include it.
set -euo pipefail
cd /root/fuxi/fork-device
git fetch -q origin old
git reset -q --hard origin/old

mkdir -p package
cp /mnt/e/DSH-Fuxi/unixnu-build/unixnu/build/original-static-system-trust/original-static-system.bundle \
   package/trust-cache.bundle
ls -l package/trust-cache.bundle
sha256sum package/trust-cache.bundle | cut -c1-32

git add -f package/trust-cache.bundle
git -c user.name=dsh -c user.email=dsh@local commit -q -m "package: ship the pinned static+system trust cache bundle"
git push -q origin old
echo "已推送"
echo "raw URL: https://raw.githubusercontent.com/yigezhong011-ops/unixnu-fuxi/old/package/trust-cache.bundle"
