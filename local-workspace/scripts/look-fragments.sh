#!/bin/bash
set -uo pipefail
cd /root/UniXNU
echo "=== arch common.config ==="
cat profiles/arch/arm64/configs/common.config
echo
echo "=== os ipados.config ==="
cat "profiles/os/ipados-17.7.11-21H461/configs/ipados.config" 2>/dev/null | head -40
echo
echo "=== soc sm8550.config（从远端拉过一份看）==="
curl -fsSL https://raw.githubusercontent.com/UniXNU/UniXNU-sm8550-common/main/configs/sm8550.config 2>/dev/null || echo "(拉取失败)"
