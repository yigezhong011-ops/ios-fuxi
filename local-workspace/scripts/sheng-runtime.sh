#!/bin/bash
# sheng's [payload.runtime] spec and its builder tool: the source build of the GPU addon + owner trust bundle.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
raw() { curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/$1"; }
D=/mnt/e/DSH-Fuxi/read/ci; mkdir -p $D
raw UniXNU/UniXNU-sheng/main/board.toml > $D/sheng-board.toml
python3 - <<'EOF'
import tomllib
b = tomllib.load(open('/mnt/e/DSH-Fuxi/read/ci/sheng-board.toml', 'rb'))
print('package:', b.get('package'))
print('runtime:', b.get('payload', {}).get('runtime'))
EOF
TOOL=$(python3 -c "import tomllib; print(tomllib.load(open('$D/sheng-board.toml','rb'))['payload']['runtime']['tool'])")
echo "tool: $TOOL"
raw UniXNU/UniXNU/main/$TOOL > $D/runtime-tool.py 2>/dev/null || raw UniXNU/UniXNU-sheng/main/$TOOL > $D/runtime-tool.py
wc -l $D/runtime-tool.py
grep -nE "run\(|subprocess|scripts/|\.py'|request\[" $D/runtime-tool.py | head -50 | cut -c1-200
