#!/bin/bash
python3 /mnt/e/DSH-Fuxi/dump/wsl/lag-study.py
A=/root/fuxi/src-adrenometal; U=/root/fuxi/src-unixnu; P=7e0d3d2ebaecd736784de0baa09254b7f63bc150; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
echo "===== priming in the plugin"
git -C $A grep -n -E 'quiet|Prime|prime_' $P -- '*.mm' '*.h' '*.cpp' 2>/dev/null | sed "s/^$P://" | grep -i -E 'quiet|idle|thread|sleep|priority|qos|nice|delay|concurr|interval' | cut -c1-170 | head -24
echo "===== upstream: performance commits after the plugin pin"
git -C $A log $P..origin/main --format='%h %cI %s' 2>/dev/null | grep -i -E 'perf|slow|stall|fence|lag|frame|fast|latency|smooth|jank|wait|poll|sleep|cache' | cut -c1-120 | head -25
echo "===== upstream: cpu / freq commits"
git -C $U log origin/main --format='%h %cI %s' -i --grep='cpufreq\|cpu freq\|big core\|prime core\|cluster\|performance core\|DCVS\|gpu perf\|cpu scal' | cut -c1-120 | head -25
