#!/bin/bash
# unixnu-ci: under loose_submodules, the same plugin build fixes the older path has: no -Werror for the Xcode 26.6 unused function, and the OS image's metallib list. Normal push; token in a header only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
echo '== the two errors'; grep -E 'error:' /tmp/ci-job.txt | grep -v '##\[error\]' | cut -c1-170 | head -8
U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64
git -C $U show $B:scripts/build-adreno-metal-plugin.py | grep -nE 'Werror|prime-list|prime_section|PRIME' | cut -c1-130 | head -10
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G
python3 -I - <<'EOF'
p = '.github/workflows/fuxi-gpu.yml'
t = open(p, newline='').read()
a = "                  print('fixed', f.name, c)\n          PY\n"
assert t.count(a) == 1
t = t.replace(a, a + "          sed -i '' \"s/'-Wall', '-Wextra', '-Werror',/'-Wall', '-Wextra', '-Werror', '-Wno-error',/\" UniXNU/scripts/build-adreno-metal-plugin.py\n          grep -c \"Wno-error\" UniXNU/scripts/build-adreno-metal-plugin.py\n          mkdir -p UniXNU/build\n          cp ci-self/ci/patches/prime-list.txt UniXNU/build/prime-list.txt\n")
open(p, 'w', newline='').write(t)
EOF
grep -n "own = " .github/workflows/fuxi-gpu.yml | cut -c1-110
test -f ci/patches/prime-list.txt
python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/fuxi-gpu.yml')); print('yaml ok')" 2>&1 | tail -1
if git diff | grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo secret; exit 1; fi
git add -A
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: plugin build fixes for the build-boot-runtime path under loose_submodules"
git -c http.extraheader="$AUTH" push -q origin HEAD:main
git log --oneline -1 | cut -c1-80
curl -fsSL -X POST "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/dispatches" -d '{"ref":"main","inputs":{"unixnu_ref":"da3736a71dfedc8b07ccebc596c9249763b3da88","build_kernel":"false","loose_submodules":"true"}}' && echo dispatched
sleep 12
curl -fsSL "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/runs?per_page=1" | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])' | tee /tmp/ci-run-id.txt
tr -d '\r' < $E/dump/wsl/wait-ci.sh > /tmp/wci.sh
bash /tmp/wci.sh "$(cut -d' ' -f1 /tmp/ci-run-id.txt)"
