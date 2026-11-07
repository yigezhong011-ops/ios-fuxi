#!/bin/bash
set -uo pipefail
cd /root/uefi-fuxi
echo "=== NuGet 配置 ==="
find . -maxdepth 2 -iname 'NuGet.Config' 2>/dev/null | head -5
for f in $(find . -maxdepth 2 -iname 'NuGet.Config' | head -2); do echo "--- $f"; cat "$f"; done
echo
echo "=== 依赖声明 ==="
find . -maxdepth 3 -name '*.dsc' -o -maxdepth 3 -name 'environment.yaml' 2>/dev/null | head -5
echo
echo "=== nuget 是否可用 ==="
which nuget mono 2>&1
nuget help 2>&1 | head -3
