#!/bin/bash
set -uo pipefail
P=/mnt/e/DSH-Fuxi/pkg/fuxi-ios-working/src/probe.c
echo "=== probe_main 定义 ==="
grep -n 'void probe_main' "$P"
LINE=$(grep -n 'void probe_main' "$P" | cut -d: -f1)
sed -n "${LINE},$((LINE+40))p" "$P"
