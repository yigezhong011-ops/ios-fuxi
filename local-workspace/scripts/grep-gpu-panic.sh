#!/bin/bash
set -uo pipefail
D=/root/ios-fuxi/xnu/fuxi-adreno
echo "=== GPU 超时/挂死路径：是否 panic ==="
grep -n 'panic\|watchdog\|HANG\|timeout\|isolat' "$D"/fuxi_gpu_abi_backend.inc | head -20
echo
echo "=== user client 里的 panic/kill ==="
grep -n 'panic\|kill\|terminate\|SIGKILL' "$D"/FuxiAdrenoUserClient.cpp | head -12
echo
echo "=== fuxi_adreno.c 里的 panic ==="
grep -n 'panic' "$D"/fuxi_adreno.c | head -12
