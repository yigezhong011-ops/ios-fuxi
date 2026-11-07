#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/dump/fuxi-dump/fdt
dtc -I dtb -O dts "$F" 2>/dev/null > /root/fuxi/fuxi-live.dts
echo "dts 生成: $(wc -l < /root/fuxi/fuxi-live.dts) 行"
python3 - <<'PY'
import re
d = open('/root/fuxi/fuxi-live.dts').read()

def show(name, span=1200):
    i = d.find(name)
    if i < 0:
        print(f'{name}: 未找到'); return
    seg = d[i:i+span]
    print(f'=== {name} ===')
    for line in seg.splitlines()[:26]:
        s = line.strip()
        if s and any(k in s for k in ('reg =', 'resource-name', 'init-voltage', 'regulator-name', 'regulator-min', 'regulator-max', 'qcom,', 'phandle')):
            print('   ', s)
    print()

show('rpmh-regulator-ldob12')
show('rpmh-regulator-ldom6')

# RSC 节点
print('=== RSC / apps_rsc 节点 ===')
for m in re.finditer(r'(\w*rsc\w*@[0-9a-f]+) \{', d):
    print('  ', m.group(1))
for m in re.finditer(r'compatible = "(qcom,[a-z0-9-]*rsc[a-z0-9-]*)";', d):
    print('   compatible:', m.group(1))
PY
