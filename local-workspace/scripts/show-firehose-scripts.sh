#!/bin/bash
set -uo pipefail
echo "=== UniXNU 的 build-firehose.sh（前 40 行）==="
sed -n '1,40p' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/scripts/build-firehose.sh 2>/dev/null || \
  sed -n '1,40p' /mnt/e/DSH-Fuxi/unixnu-build/unixnu/out/fuxi/tree/scripts/build-firehose.sh 2>/dev/null
echo
echo "=== Allenwdk 的 build-firehose-linux.sh（前 40 行）==="
sed -n '1,40p' /mnt/e/DSH-Fuxi/unixnu-build/xnu-linux-toolchain/scripts/build-firehose-linux.sh 2>/dev/null
