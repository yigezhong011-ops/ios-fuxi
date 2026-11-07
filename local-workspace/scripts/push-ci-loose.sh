#!/bin/bash
# unixnu-ci workflow: optional loose_submodules input, for a plugin-only build of a revision with a submodule pin its repository no longer has. Off by default. Normal push; token in a header only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G
python3 -I - <<'EOF'
p = '.github/workflows/fuxi-gpu.yml'
t = open(p, newline='').read()
a = "      build_kernel:\n"
assert t.count(a) == 1
t = t.replace(a, "      loose_submodules:\n        description: Skip UniXNU submodules whose pinned commit cannot be fetched (plugin-only builds)\n        type: boolean\n        default: false\n" + a)
b = "          ref: ${{ inputs.unixnu_ref }}\n          path: UniXNU\n          submodules: recursive\n          persist-credentials: false\n"
assert t.count(b) == 1
t = t.replace(b, "          ref: ${{ inputs.unixnu_ref }}\n          path: UniXNU\n          submodules: ${{ inputs.loose_submodules && 'false' || 'recursive' }}\n          persist-credentials: false\n      - name: loose submodules\n        if: inputs.loose_submodules\n        run: |\n          for s in $(git -C UniXNU config -f .gitmodules --get-regexp '\\.path$' | awk '{print $2}'); do\n            git -C UniXNU submodule update --init --recursive --depth 1 -- \"$s\" || git -C UniXNU submodule update --init --recursive -- \"$s\" || echo \"SKIPPED $s\"\n          done\n          for s in drivers/Adreno740 drivers/AdrenoMetal kits/AdrenoPM4; do test -n \"$(ls -A UniXNU/$s)\"; done\n")
open(p, 'w', newline='').write(t)
EOF
python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/fuxi-gpu.yml')); print('yaml ok')" 2>&1 | tail -1
if git diff | grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo secret; exit 1; fi
git diff --stat | tail -2 | cut -c1-90
git add -A
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: optional loose_submodules for plugin-only builds

UniXNU feat/metal2vulkan-963f0e64 pins a drivers/ArmCpu commit its repository does not have. A plugin build does not use it."
git -c http.extraheader="$AUTH" push -q origin HEAD:main
git log --oneline -1 | cut -c1-80
curl -fsSL -X POST "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/dispatches" -d '{"ref":"main","inputs":{"unixnu_ref":"da3736a71dfedc8b07ccebc596c9249763b3da88","build_kernel":"false","loose_submodules":"true"}}' && echo dispatched
sleep 12
curl -fsSL "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/runs?per_page=1" | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])' | tee /tmp/ci-run-id.txt
tr -d '\r' < $E/dump/wsl/wait-ci.sh > /tmp/wci.sh
bash /tmp/wci.sh "$(cut -d' ' -f1 /tmp/ci-run-id.txt)"
