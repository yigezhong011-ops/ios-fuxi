#!/bin/bash
set -uo pipefail
echo "=== 我们树里的 mockfs ==="
ls /root/ux3/fuxi/tree/scripts/ 2>/dev/null | grep -i mockfs
ls /root/ux3/fuxi/tree/kits/sheng/ 2>/dev/null | grep -i mockfs
echo
echo "=== 他们树里的 mockfs ==="
ls /root/fuxi/fuxi2/scripts/ | grep -i mockfs
echo
echo "=== build-mockfs-fixture.py 的作用（前 30 行）==="
head -30 /root/fuxi/fuxi2/scripts/build-mockfs-fixture.py 2>/dev/null | cut -c1-140
