#!/bin/bash
# Read-only: where the scanout wait counters live, locally and in the t50 kernel and addon.
cd /root/fuxi || exit 1
echo "=== source files naming scanout wait"
grep -rlIE 'scanout wait|scanout_wait|ScanoutWait|scanoutWait' src-adreno740 src-adrenometal unixnu-pin/drivers fuxi2/package fuxi2/kits ref-fuxi-v2/package ref-sad-fuxi/package gpu-plugin-1105 2>/dev/null | head -20
echo "=== lines"
grep -rnIE 'scanout wait|scanout prepare' src-adreno740 src-adrenometal unixnu-pin/drivers fuxi2/package ref-fuxi-v2/package 2>/dev/null | cut -c1-210 | head -16
echo "=== t50 kernel strings"
strings -a t50/kernel.macho | grep -E 'scanout (wait|prepare)|\[scanout' | cut -c1-200 | sort -u | head -10
llvm-nm t50/kernel.macho | grep -iE 'scanout' | cut -c18- | head -30
echo "=== addon plugin strings"
ls addon-new gpu-new-t50-mine 2>/dev/null | head -12 | tr '\n' ' '; echo
echo "=== read-sheng-log rows"
grep -n 'scanout' /root/build/fuxi/scripts/read-sheng-log.py | cut -c1-170 | head -12
