#!/bin/bash
# Offline test of deepseek-gpu.sh: syntax, workflow YAML, status, and the install path on a run with no addon inside
# (it must stop at the unpack check and write no image). Dispatches nothing.
cd /mnt/e/DSH-Fuxi/dump/wsl
sed -i 's/\r$//' deepseek-gpu.sh deepseek-gpu-run.sh install-gpu-addon.sh
bash -n deepseek-gpu.sh && bash -n deepseek-gpu-run.sh && bash -n install-gpu-addon.sh && echo syntax-ok
python3 - <<'EOF'
import yaml
d = yaml.safe_load(open('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml'))
print(d['jobs']['build']['runs-on'], [s.get('name') for s in d['jobs']['build']['steps']][:1], list(d[True]['workflow_dispatch']['inputs']))
EOF
bash deepseek-gpu.sh status | cut -c1-80
bash deepseek-gpu.sh install 41600249907
echo "install-exit=$?"
ls -la /mnt/e/DSH-Fuxi/*-gpu-fix.img 2>&1
