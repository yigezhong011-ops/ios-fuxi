#!/bin/bash
set -uo pipefail
echo "=== apt 日志 ==="
tail -5 /root/nuget-install.log 2>/dev/null || echo "(无)"
echo "=== dpkg 检查 ==="
dpkg -L nuget 2>/dev/null | head -5 || echo "(nuget 包未安装)"
echo "=== 直接下载 nuget.exe ==="
curl -fsSL --retry 3 https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -o /usr/local/bin/nuget.exe
ls -lh /usr/local/bin/nuget.exe
printf '#!/bin/sh\nexec mono /usr/local/bin/nuget.exe "$@"\n' > /usr/local/bin/nuget
chmod +x /usr/local/bin/nuget
nuget help 2>&1 | head -3
