#!/bin/bash
set -uo pipefail
echo "=== 删除前 ==="
df -h / | tail -1
rm -f /root/fuxi/root-1616.img
rm -f /root/fuxi/root-iphonex.img
rm -rf /root/fuxi/build-x
rm -rf /root/wslkernel
echo "=== 删除后 ==="
df -h / | tail -1
du -sh /root/fuxi 2>/dev/null
ls -lh /root/fuxi/*.img 2>/dev/null
