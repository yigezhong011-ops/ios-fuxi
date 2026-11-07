#!/bin/bash
set -uo pipefail
Y=/root/uefi-fuxi/Mu_Basecore/BaseTools/Bin/nasm_ext_dep.yaml
cp "$Y" "$Y.orig" 2>/dev/null || true
python3 - "$Y" <<'PY'
import pathlib, sys, re
p = pathlib.Path(sys.argv[1])
t = p.read_text()
t2 = re.sub(r'"source":\s*"[^"]*"', '"source": "/root/local-feed"', t, count=1)
p.write_text(t2)
print('patched source ->', [l for l in t2.splitlines() if 'source' in l])
PY
echo "=== 也检查 basetoolsbin/iasl 是否同样来自 azure ==="
grep -h '"source"' /root/uefi-fuxi/Mu_Basecore/BaseTools/Bin/*_ext_dep.yaml 2>/dev/null | sort -u
