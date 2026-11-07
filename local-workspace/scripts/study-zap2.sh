#!/bin/bash
# Read-only: the zap code in V2's GPU power probe, and the good boot's slots around the zap mark.
V=/root/fuxi/ref-fuxi-v2
git -C $V show HEAD:package/GpuPowerProbe.cpp | sed -n 36,60p | cut -c1-170
git -C $V show HEAD:package/GpuPowerProbe.cpp | sed -n 545,690p | cut -c1-150
echo "=== good boot"
grep -a -n -E 'S zap|Z[0-9]+/[0-9]+|S [a-z0-9_]+' /root/fuxi/cad-ab/untagged-6798de11ea/slots.txt | cut -c1-120 | head -40
