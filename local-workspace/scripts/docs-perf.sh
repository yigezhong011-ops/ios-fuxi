#!/bin/bash
set -uo pipefail
echo "=== ios-fuxi 文档里的帧率/性能说明 ==="
grep -rn -i 'fps\|frame rate\|帧\|卡顿\|laggy\|perf' /root/ios-fuxi/docs/sweet.md /root/ios-fuxi/docs-lanes/unixnu-port.md 2>/dev/null | head -12
echo
echo "=== gpu.md 里的 CPU 渲染速度实测 ==="
grep -rn -i 'fps\|copy avg\|10 GB/s\|1.24\|ms per frame' /root/ios-fuxi/docs-lanes/gpu.md 2>/dev/null | head -12
echo
echo "=== touch-display.md 的刷新率说明 ==="
grep -rn -i 'hz\|refresh\|60\|120' /root/ios-fuxi/docs-lanes/touch-display.md 2>/dev/null | head -10
