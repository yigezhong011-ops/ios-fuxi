#!/bin/bash
set -uo pipefail
cd /root/uefi-fuxi
echo "=== 仓库里是否已有预编译 FD ==="
find . -name '*.fd' -o -name 'SILICIUM_UEFI*' 2>/dev/null | head -10 || echo "(无)"
echo
echo "=== 直接下载 nupkg（绕过 mono 的 TLS）==="
curl -fsSL --retry 2 -o /root/mu_nasm.nupkg https://api.nuget.org/v3-flatcontainer/mu_nasm/20016.1.1/mu_nasm.20016.1.1.nupkg && ls -lh /root/mu_nasm.nupkg || echo "下载失败"
echo
echo "=== pytool 期望的依赖目录 ==="
grep -rn 'extdep\|NugetDependency\|mu_nasm' Mu_Basecore/BaseTools/Bin/*/*.json 2>/dev/null | head -5
ls Mu_Basecore/BaseTools/Bin/ 2>/dev/null | head -10
