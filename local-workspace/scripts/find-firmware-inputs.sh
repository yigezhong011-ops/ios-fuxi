#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/fuxi
echo "=== fuxi_adreno_common.py 里的固件路径 ==="
grep -n 'firmware\|cache\|zap\|mbn' "$D/scripts/fuxi_adreno_common.py" 2>/dev/null | head -20
echo
echo "=== data/adreno-inputs.json 里的固件条目 ==="
ls "$D/scripts/data" 2>/dev/null | head
python3 - "$D/scripts/data/adreno-inputs.json" <<'PY' 2>/dev/null
import json, sys
d = json.load(open(sys.argv[1]))
fw = d.get('firmware', {})
print('firmware 键:', list(fw.keys())[:5])
files = fw.get('files', {})
for k, v in list(files.items())[:8]:
    print('  %-40s %s bytes  sha256 %s' % (k, v.get('bytes'), str(v.get('sha256'))[:16]))
PY
echo
echo "=== build-adreno740-kits.py 里固件从哪读 ==="
grep -n 'firmware\|zap\|mbn\|cache' "$D/scripts/build-adreno740-kits.py" 2>/dev/null | head -14
