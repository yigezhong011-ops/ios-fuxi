#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=== profiles ==="
ls profiles
echo "=== profiles/os ==="
ls profiles/os 2>/dev/null
echo "=== profiles/arch/arm64 ==="
ls profiles/arch/arm64 2>/dev/null | head -20
echo "=== 哪些文件提到 BCM2837 ==="
grep -rl 'BCM2837' --include='*.toml' --include='*.py' . | head -10
echo "=== 哪些文件提到 SM8550 ==="
grep -rl 'SM8550' --include='*.toml' --include='*.py' . | head -10
echo "=== devices.toml 全文 ==="
cat devices.toml
