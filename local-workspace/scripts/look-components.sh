#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=== components.toml 的组件清单 ==="
grep -n '^id = ' components.toml
echo
echo "=== corecrypto 相关条目 ==="
grep -n -A8 'CoreCrypto' components.toml | head -40
