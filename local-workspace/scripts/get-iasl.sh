#!/bin/bash
set -uo pipefail
Y=/root/uefi-fuxi/Mu_Basecore/BaseTools/Bin/iasl_ext_dep.yaml
echo "=== iasl 依赖声明 ==="
grep -E '"name"|"version"|"source"' "$Y"
NAME=$(grep -oP '"name":\s*"\K[^"]+' "$Y" | head -1)
VER=$(grep -oP '"version":\s*"\K[^"]+' "$Y" | head -1)
SRC=$(grep -oP '"source":\s*"\K[^"]+' "$Y" | head -1)
echo "name=$NAME ver=$VER"
python3 - "$SRC" "$NAME" "$VER" <<'PY'
import json, subprocess, sys, pathlib
src, name, ver = sys.argv[1], sys.argv[2], sys.argv[3]
out = subprocess.run(['curl','-fsSL','--retry','2',src], capture_output=True, text=True)
if out.returncode != 0:
    print('index fetch failed'); sys.exit(1)
idx = json.loads(out.stdout)
base = next((r['@id'] for r in idx['resources'] if 'PackageBaseAddress' in r.get('@type','')), None)
print('base:', base)
url = f"{base.rstrip('/')}/{name.lower()}/{ver}/{name.lower()}.{ver}.nupkg"
print('url:', url)
subprocess.run(['curl','-fsSL','--retry','2',url,'-o',f'/root/local-feed/{name.lower()}.{ver}.nupkg'], check=True)
print('downloaded')
PY
ls -lh /root/local-feed/
# 把 iasl 的 source 也改到本地
python3 - "$Y" <<'PY'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1]); t = p.read_text()
p.write_text(re.sub(r'"source":\s*"[^"]*"', '"source": "/root/local-feed"', t, count=1))
print('iasl source patched')
PY
