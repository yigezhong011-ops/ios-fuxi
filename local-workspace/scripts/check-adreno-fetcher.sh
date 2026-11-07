#!/bin/bash
set -uo pipefail
T=/root/ux3/fuxi/tree
echo "=== fuxi_adreno_common.ensure_adreno_cache ==="
sed -n '80,110p' "$T/scripts/fuxi_adreno_common.py" 2>/dev/null | cut -c1-170
echo
echo "=== 它调用的 fetcher ==="
ls "$T/scripts" | grep -i 'fetch.*adreno\|adreno.*fetch' | head -3
F=$(ls "$T"/scripts/*fetch*adreno*.py 2>/dev/null | head -1)
[ -n "$F" ] && grep -n 'api.github\|raw.github\|url\|blob' "$F" | head -8 | cut -c1-170
