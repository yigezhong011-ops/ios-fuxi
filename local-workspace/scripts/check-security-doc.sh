#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
echo "=== security.md 里与 trust / kernel 相关 ==="
grep -rn -i 'trust\|signature\|amfi\|compromis' "$D/concepts/security.md" 2>/dev/null | head -16 | cut -c1-180
echo
echo "=== 全文档搜 Compromised ==="
grep -rn -i 'compromis' "$D" --include='*.md' 2>/dev/null | head -8 | cut -c1-180
echo
echo "=== 全文档搜 trust cache 与内核哈希 ==="
grep -rn -i 'cd hash\|cdhash\|kernel hash' "$D" --include='*.md' 2>/dev/null | head -8 | cut -c1-180
