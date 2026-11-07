#!/bin/bash
set -uo pipefail
echo "=== LZFSE / img4 工具 ==="
for t in lzfse lzfse-cli img4 im4p ipsw; do
  printf '%-12s %s\n' "$t" "$(command -v $t || echo MISSING)"
done
python3 - <<'PY'
for mod in ('lzfse', 'plistlib', 'asn1'):
    try:
        __import__(mod); print(f'python {mod}: OK')
    except Exception as e:
        print(f'python {mod}: {type(e).__name__}')
PY
echo
echo "=== 系统里有没有 liblzfse ==="
ldconfig -p 2>/dev/null | grep -i lzfse | head -3 || echo none
