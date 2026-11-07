#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/unixnu/payload/ipados-17.7.11-21H461/fuxi/payload/payload.img
echo "=== payload.img 内容（mtools 列目录）==="
command -v mdir >/dev/null || apt-get install -y mtools >/dev/null 2>&1
mdir -i "$P" -/ :: 2>&1 | head -30
echo
echo "=== unixnu.toml 是否在 EFI/UniXNU ==="
mtype -i "$P" ::/EFI/UniXNU/unixnu.toml 2>&1 | head -20
echo
echo "=== Payloads 目录 ==="
mdir -i "$P" ::/EFI/UniXNU/Payloads 2>&1 | head -10
