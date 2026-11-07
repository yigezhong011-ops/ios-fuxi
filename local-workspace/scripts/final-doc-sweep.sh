#!/bin/bash
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/docs
echo "=== 文档里 NativeMetal vs AdrenoMetal ==="
grep -rn 'NativeMetal' "$D" --include='*.md' | head -8 | cut -c1-170
echo
echo "=== 文档里 accelerator ==="
grep -rn -i 'accelerator' "$D" --include='*.md' | grep -i 'adreno\|metal\|build' | head -8 | cut -c1-170
echo
echo "=== 文档里 legacy-stub ==="
grep -rn 'legacy-stub\|LegacyStub' "$D" --include='*.md' | head -6 | cut -c1-170
