#!/bin/bash
set -uo pipefail
D=/root/fuxi/uni-fork/docs
echo "=== security.md 里 root / owner 相关 ==="
grep -n -i 'owner root\|root auth\|rootvp\|unsealed\|root-volume\|os_volume_uuid' "$D/concepts/security.md" 2>/dev/null | head -20 | cut -c1-165
echo
echo "=== ufs.md 里 root 相关 ==="
grep -n -i 'root\|auth\|owner' "$D/porting/ufs.md" 2>/dev/null | head -20 | cut -c1-165
