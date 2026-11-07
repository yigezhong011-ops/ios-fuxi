#!/bin/bash
set -uo pipefail
echo "=== 仓库里的 RPMh / RSC 实现 ==="
grep -rln -i 'rpmh\|apps_rsc\|rsc_' /root/ios-fuxi/xnu/ 2>/dev/null | grep -v '\.patch' | head -8
echo
echo "=== fuxi-h1 里的电源相关文件 ==="
grep -rn -i 'rpmh\|rsc' /root/ios-fuxi/xnu/fuxi-h1/*.c 2>/dev/null | head -10
echo
echo "=== 设备树里 rpmh-regulator-ldob12 的完整定义 ==="
python3 - <<'PY'
import re
d = open('/tmp/fuxi.dts').read()
for name in ('rpmh-regulator-ldob12', 'rpmh-regulator-ldom6'):
    i = d.find(name)
    if i < 0:
        print(name, '未找到'); continue
    seg = d[i-200:i+900]
    print(f'=== {name} ===')
    for line in seg.splitlines()[:30]:
        if any(k in line for k in ('reg =', 'resource-name', 'init-voltage', 'regulator-name', 'regulator-min', 'regulator-max', 'qcom,')):
            print('  ', line.strip())
PY
