#!/bin/bash
set -uo pipefail
echo "=== 当前 ci/fuxi-gpu.yml 的关键步骤 ==="
grep -nE 'name:|run:|404|preflight|no-replay|gen-turnip|build-turnip|build-adreno-metal|vulkan|macos-' /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml | head -40 | cut -c1-140
echo
echo "=== 文件大小与修改时间 ==="
ls -l /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml
