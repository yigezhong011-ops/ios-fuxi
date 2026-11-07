#!/bin/bash
set -uo pipefail
echo "=== 文档里 metal 相关的 boot-arg / 启用条件 ==="
grep -rn -i 'fuximetal\|fuximtl\|metal=1\|metal-clients\|FuxiMetal' /root/ios-fuxi/docs-lanes/*.md /root/ios-fuxi/docs/*.md 2>/dev/null | head -20
echo
echo "=== CA / CoreAnimation GPU 相关 ==="
grep -rn -i 'coreanimation\|CA 渲染\|backboardd.*gpu\|GPU 绘制' /root/ios-fuxi/docs-lanes/*.md 2>/dev/null | head -12
