#!/bin/bash
set -uo pipefail
cd /root
echo "=== 试着从 nuget.org 拉 mu_nasm ==="
nuget install mu_nasm -Version 20016.1.1 -OutputDirectory /root/nuget-test -Source https://api.nuget.org/v3/index.json 2>&1 | tail -8
echo "=== 结果 ==="
ls /root/nuget-test 2>/dev/null || echo "(无)"
echo
echo "=== pytool 的依赖缓存位置 ==="
ls -d /root/.cache/edk2-pytool-extensions 2>/dev/null && find /root/.cache/edk2-pytool-extensions -maxdepth 3 -iname '*nasm*' 2>/dev/null | head -5
echo
echo "=== 环境依赖声明 ==="
grep -rn 'mu_nasm' /root/uefi-fuxi/*.json /root/uefi-fuxi/*.yaml 2>/dev/null | head -5
find /root/uefi-fuxi -maxdepth 2 -name '*.json' -newer /root/uefi-fuxi/README.md 2>/dev/null | head -5
