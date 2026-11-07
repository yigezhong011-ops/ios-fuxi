#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/dump/fuxi-dump/fdt
dtc -I dtb -O dts "$F" 2>/dev/null > /tmp/fuxi.dts
echo "=== phandle 0x2f3 和 0x2a 对应的 regulator 节点 ==="
python3 - <<'PY'
import re
d = open('/tmp/fuxi.dts').read()
for ph in ('0x2f3', '0x2a'):
    print(f'=== phandle {ph} ===')
    # 找 phandle = <0x2f3> 的节点及其上方 25 行
    for m in re.finditer(r'phandle = <' + ph + r'>;', d):
        start = d.rfind('\n', 0, m.start() - 2000)
        seg = d[max(0, m.start()-1500):m.end()+200]
        # 取节点名（最后一个 xxx { 之前）
        names = re.findall(r'([A-Za-z0-9_,@.-]+) \{', seg)
        props = re.findall(r'(regulator-name|reg = <[^>]*>|qcom,[a-z-]+|spmi[^;]*;)', seg)
        print('  节点候选:', names[-3:])
        print('  属性:', props[-6:])
    print()
PY
