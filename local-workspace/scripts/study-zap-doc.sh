#!/bin/bash
# Read-only: what the driver docs say about the coherence probe and the secure-mode step of GPU bring-up.
D=/root/fuxi/unixnu-pin/docs/zh/drivers/adreno740.md
wc -l "$D"
echo "=== coherence / d0"
grep -nE 'd0/64|int-15[0-9]|一致性|coheren' "$D" | cut -c1-260 | head -14
echo "=== secure / zap / hang"
grep -nEi 'zap|secure|安全模式|卡死|挂起|hang' "$D" | cut -c1-260 | head -14
echo "=== other docs"
grep -rlEi 'exit.?secure|SECVID|zap' /root/fuxi/unixnu-pin/docs/zh 2>/dev/null | head
echo "=== Z rows in the probe source"
grep -nE 'Z%|"Z[0-9 ]|S zap|setRow\(.*Z' /root/fuxi/fuxi2/package/GpuPowerProbe.cpp | cut -c1-170 | head -14
