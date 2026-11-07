#!/bin/bash
# Read-only: coherenceProbe in the source, where it is called, and the notes from other devices.
V=/root/fuxi/ref-fuxi-v2
F=/tmp/gp.cpp
git -C $V show HEAD:package/GpuPowerProbe.cpp > $F
grep -n -E 'coherenceProbe|gCoherenceAttempts|native_gpu_coherence' $F | cut -c1-140
s=$(grep -n 'coherenceProbe(NativeAdrenoVm' $F | head -1 | cut -d: -f1)
sed -n "$((s-22)),$((s+95))p" $F | cut -c1-175
echo "=== asteroids notes"
U=/root/fuxi/up-latest
git -C $U show HEAD:docs/devices/asteroids.md | grep -n -i -E 'coheren' | cut -c1-420 | head -12
git -C $U show HEAD:docs/.vitepress/device-records/alioth.toml | grep -n -i -E 'coheren' | cut -c1-420 | head -8
echo "=== driver"
git -C /root/fuxi/src-adreno740 show HEAD:NativeAdrenoSmmuMemory.cpp | grep -n -i -E 'coheren' | cut -c1-170 | head -24
