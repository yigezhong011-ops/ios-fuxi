#!/bin/bash
set -uo pipefail
V=/root/fuxi/t36-usb-trace5/vol.img
mtype -i "$V" ::/EFI/UniXNU/unixnu.toml > /root/fuxi/trace5.toml 2>/dev/null
echo "=== 文件大小 ==="
wc -c < /root/fuxi/trace5.toml
echo "=== 能否解析为 TOML ==="
python3 - <<'PY'
import tomllib
from pathlib import Path
p = Path('/root/fuxi/trace5.toml')
raw = p.read_bytes()
print('ending bytes:', raw[-40:])
try:
    d = tomllib.loads(raw.decode('utf-8', 'replace'))
    print('解析成功，顶层键:', list(d.keys()))
    for e in d.get('entry', []):
        print('  entry:', {k: (v[:40] if isinstance(v, str) else v) for k, v in e.items() if k in ('title','action','args')})
    args = None
    for e in d.get('entry', []):
        if 'args' in e:
            args = e['args']
    print('args 字符数:', len(args) if args else None)
except Exception as ex:
    print('解析失败:', ex)
PY
