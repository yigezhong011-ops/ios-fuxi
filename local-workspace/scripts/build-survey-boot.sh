#!/bin/bash
set -euo pipefail
sed -e 's/fuxibbgpu=1/fuxibbgpu=2/g' \
    -e 's#fuxi-metal-boot.img#fuxi-metal-survey.img#g' \
    /mnt/e/DSH-Fuxi/dump/wsl/build-metal-boot.sh > /tmp/survey.sh
grep -n 'fuxibbgpu=' /tmp/survey.sh | head -3
bash /tmp/survey.sh 2>&1 | tail -8
