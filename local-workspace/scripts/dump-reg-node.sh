#!/bin/bash
set -uo pipefail
python3 - <<'PY'
import re
d = open('/root/fuxi/fuxi-live.dts').read()
for name in ('rpmh-regulator-ldob12', 'rpmh-regulator-ldom6'):
    i = d.find(name)
    if i < 0:
        print(name, 'NOT FOUND'); continue
    # 跳到节点结尾（匹配大括号）
    j = d.find('{', i)
    depth = 0
    k = j
    while k < len(d):
        if d[k] == '{': depth += 1
        elif d[k] == '}':
            depth -= 1
            if depth == 0: break
        k += 1
    node = d[i:k+1]
    print(f'=== {name} ===')
    print(node[:1200])
    print()
PY
