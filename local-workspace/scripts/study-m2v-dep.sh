#!/bin/bash
# Read-only: how the bridge gets metal2vulkan, at our pin and at upstream's fix, and where the two methods came from.
L=/root/fuxi/ci-41937514030.log
grep -n -E 'metal2vulkan' $L | cut -c30-220 | head -14
grep -n -B2 -A14 'E0599' $L | cut -c30-200 | head -50
cd /root/fuxi/plugin-try
git log -1 --format='%h %s' | cut -c1-80
grep -rn -E 'metal2vulkan' --include=Cargo.toml --include='*.lock' --include='*.py' . 2>/dev/null | cut -c1-200 | head -14
git submodule status 2>/dev/null | cut -c1-100 | head
for c in 7e0d3d2 8c1ea13 5a50581; do echo "-- $c"; git show $c:bridge/Cargo.toml 2>/dev/null | grep -n -A3 metal2vulkan | cut -c1-160 | head -8; git ls-tree $c | grep -E 'commit' | cut -c1-90; done
cd /root/fuxi/up-latest
grep -n -E 'metal2vulkan' scripts/build-adreno-metal-bridge.py scripts/build-adreno-metal-plugin.py | cut -c1-180 | head -14
find /root/fuxi -maxdepth 2 -iname '*metal2vulkan*' 2>/dev/null | head
