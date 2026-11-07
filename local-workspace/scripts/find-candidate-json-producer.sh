#!/bin/bash
set -uo pipefail
D=/root/fuxi/fork-device/scripts
echo "=== 引用 native-prelink 的脚本 ==="
grep -rln 'native-prelink' "$D"/*.py | sed 's|.*/||' | tr '\n' ' '; echo
echo
echo "=== 其中写入 json 的 ==="
grep -rn 'json.dump\|write_text(json' "$D"/*.py 2>/dev/null | head -10 | cut -c1-170
echo
echo "=== legacy-display 读取 json 的方式 ==="
grep -n 'json' "$D"/build-native-legacy-display.py | head -8 | cut -c1-170
