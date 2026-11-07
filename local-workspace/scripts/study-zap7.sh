#!/bin/bash
# Read-only: what runs right after the zap, the window in which hang boots stopped logging (t=12..14 s).
V=/root/fuxi/ref-fuxi-v2
F=/tmp/gp.cpp
git -C $V show HEAD:package/GpuPowerProbe.cpp > $F
grep -n -E 'zapAndSecure\(\)|irqAndTimer\(\)|zapEnd\(\)' $F | cut -c1-120
s=$(grep -n '^void irqAndTimer' $F | cut -d: -f1)
sed -n "$s,$((s+75))p" $F | cut -c1-165
echo "=== caller"
c=$(grep -n 'zapAndSecure();' $F | tail -1 | cut -d: -f1)
sed -n "$((c-14)),$((c+40))p" $F | cut -c1-165
echo "=== files in a carve"
ls -la /root/fuxi/cad-ab/untagged-6798de11ea | head -20
echo "=== t50 has these"
llvm-nm /root/fuxi/t50/kernel.macho | grep -E 'irqAndTimer|gpuIrq|armcpu_spi_attach|armcpu_spi_unhandled|native_gpu_irq' | cut -c1-90
