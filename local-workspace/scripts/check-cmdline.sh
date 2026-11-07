#!/bin/bash
set -uo pipefail
F=/mnt/e/DSH-Fuxi/dump/wsl/step11b-build-boot.sh
echo "=== 当前 cmdline ==="
grep '^CMDLINE=' "$F" | head -2
echo
echo "=== 是否含 sweetfb_noconsole ==="
if grep -q 'sweetfb_noconsole' "$F"; then
  echo "已设置"
else
  echo "未设置（控制台会盖住合成画面）"
fi
