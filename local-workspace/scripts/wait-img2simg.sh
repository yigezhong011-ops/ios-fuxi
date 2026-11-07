#!/bin/bash
# Wait for img2simg to finish, then flash the sparse image with the Windows
# fastboot (sparse images are streamed chunk by chunk, so no bad_alloc).
set -uo pipefail
D=/mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/userdata
for i in $(seq 1 60); do
  if ! pgrep -f img2simg >/dev/null 2>&1; then
    echo "转换完成（等待 $((i*5)) 秒）"
    break
  fi
  sleep 5
done
ls -lh "$D"/userdata-sparse.simg
