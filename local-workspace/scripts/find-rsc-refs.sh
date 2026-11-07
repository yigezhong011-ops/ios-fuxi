#!/bin/bash
set -uo pipefail
echo "=== hackios xnu/files 里搜 RPMh ==="
grep -rn -i 'rpmh' /root/hackios/xnu/files /root/hackios/xnu/redwood.patch 2>/dev/null | head -12
echo
echo "=== p4rfa1t 的仓库文档里搜 RSC/TCS（GPU 投票用）==="
ls /root/ios-fuxi/docs-lanes/ | grep -i 'gpu\|power' | head -5
grep -rn -i 'rpmh\|rsc\|tcs' /root/ios-fuxi/docs-lanes/gpu*.md 2>/dev/null | head -12
