#!/bin/bash
set -uo pipefail
OUT=/root/UniXNU/out/fuxi/ipados-17.7.11-21H461/fuxi
echo "=== boot 目录 ==="
ls -lah "$OUT/boot" 2>/dev/null || echo "(无)"
echo
echo "=== boot.json ==="
python3 - "$OUT/boot/boot.json" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
if p.exists():
    d = json.loads(p.read_text())
    for k, v in d.items():
        print(f'{k}: {v}')
else:
    print('(无 boot.json)')
PY
echo
echo "=== bootimg 日志（完整）==="
cat /root/unixnu-bootimg.log 2>/dev/null | tail -30
