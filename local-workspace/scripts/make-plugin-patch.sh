#!/bin/bash
# Our plugin pin 7e0d3d2 plus upstream's 8c1ea13 (complete resource interfaces, single-sample Poster) and 5a50581 (single sample for all), with their
# small conflicts resolved, as one patch for ci/patches. Host-side only: nothing is pushed here.
set -euo pipefail
cd /root/fuxi/plugin-try
git cherry-pick --abort 2>/dev/null || true
git reset -q --hard 7e0d3d2
G="git -c user.name=fuxi -c user.email=fuxi@example.invalid"
$G cherry-pick -x 8c1ea13 >/dev/null 2>&1 || true
python3 -I - <<'EOF'
import re
p = open('CacheExport.h').read()
p, n = re.subn(r'<<<<<<< [^\n]*\n=======\n(.*?)>>>>>>> [^\n]*\n', r'\1', p, flags=re.S)
assert n == 1
open('CacheExport.h', 'w').write(p)
f = open('NativeBridgeMetalFrontend.mm').read()
# Keep our journal line: logGpuOn is a later upstream helper.
f, n = re.subn(r'<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n', lambda m: m.group(1) + ' watchImportPressure();\n' if 'watchImportPressure' in m.group(2) else m.group(0), f, flags=re.S)
print('frontend conflicts resolved', n, 'left', f.count('<<<<<<<'))
open('NativeBridgeMetalFrontend.mm', 'w').write(f)
EOF
git add -A; $G -c core.editor=true cherry-pick --continue >/dev/null
$G cherry-pick -x 5a50581 >/dev/null 2>&1 || true
git diff --name-only --diff-filter=U
git diff | cut -c1-150 | head -40
echo "== helpers"; grep -n -c 'watchImportPressure' NativeBridgeMetalFrontend.mm || true; grep -n 'static.*watchImportPressure\|void watchImportPressure' NativeBridgeMetalFrontend.mm | head -3
grep -n 'logGpuOn' NativeBridgeMetalFrontend.mm | head -3
git log --oneline -3 | cut -c1-80
