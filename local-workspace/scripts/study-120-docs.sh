#!/bin/bash
# Read-only: what the upstream docs say about high refresh rate and display timing.
D=/root/build/unixnu/docs/zh
for f in devices/sheng.md devices/pong.md devices/asteroids.md devices/tb365fc.md devices/pandora.md drivers/adreno-metal.md; do
  echo "=== $f"; grep -n -i -E '120 ?hz|144 ?hz|165 ?hz|刷新率|promotion|高刷|refresh' $D/$f | cut -c1-420 | head -14
done
echo "=== records"; grep -n -i -E '120 ?hz|144 ?hz|刷新率|promotion|refresh' /root/build/unixnu/docs/.vitepress/device-records/{pong,sheng,asteroids,tb365fc}.toml | cut -c1-420 | head -24
echo "=== latest upstream?"; git -C /root/build/unixnu log -1 --format='%h %cd' --date=short; timeout 40 git ls-remote https://github.com/unixnu/UniXNU HEAD 2>&1 | cut -c1-60; git -C /root/build/unixnu remote -v | head -2
echo "=== display kernel"; grep -rIl -E 'ShengDpu|sheng_dpu|NativeLegacyDisplay|verify_swap' /root/build/unixnu/package /root/build/fuxi /root/build/uefi-fuxi --exclude-dir=.git 2>/dev/null | head -20
echo "=== t50 provenance"; grep -l -E 't50' /mnt/e/DSH-Fuxi/dump/wsl/*.sh 2>/dev/null | xargs -n1 basename | head -20
grep -n -E 't50' /mnt/e/DSH-Fuxi/progress-2026-11-03-README.md /mnt/e/DSH-Fuxi/progress-2026-11-04-gpu-ci.md | cut -c1-260 | head -20
