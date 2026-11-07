#!/bin/bash
set -uo pipefail
echo "=== build3 里的警告/错误 ==="
grep -n -i -E 'warning|error|nuget|dependenc' /root/uefi-build3.log | head -25
echo
echo "=== 是否跑过 stuart_update ==="
grep -n -i 'stuart' /root/uefi-build3.log | head -10
