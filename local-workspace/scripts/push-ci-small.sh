#!/bin/bash
# unixnu-ci: optional size_opt input: the translator and plugin built for size, for a test that must fit the addon. Normal push; token in a header only.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64
echo '== how the bridge is built'
git -C $U show $B:scripts/build-adreno-metal-bridge.py | grep -nE "cargo|profile|opt-level|lto|RUSTFLAGS|CARGO_|'-O|strip|panic" | cut -c1-140 | head -16
git -C $U show $B:scripts/build-adreno-metal-plugin.py | grep -nE "'-O2'|'-Os'|lto" | cut -c1-120 | head -6
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G
python3 -I - <<'EOF'
p = '.github/workflows/fuxi-gpu.yml'
t = open(p, newline='').read()
a = "      build_kernel:\n"
assert t.count(a) == 1
t = t.replace(a, "      size_opt:\n        description: Build the translator and plugin for size (test builds that must fit the addon)\n        type: boolean\n        default: false\n" + a)
b = "      - name: GPU addon\n"
assert t.count(b) == 1
t = t.replace(b, "      - name: size options\n        if: inputs.size_opt\n        run: |\n          {\n            echo 'CARGO_PROFILE_RELEASE_OPT_LEVEL=s'\n            echo 'CARGO_PROFILE_RELEASE_LTO=fat'\n            echo 'CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1'\n            echo 'CARGO_PROFILE_RELEASE_STRIP=symbols'\n          } >> \"$GITHUB_ENV\"\n          sed -i '' \"s/'-O2', '-g'/'-Os', '-g'/\" UniXNU/scripts/build-adreno-metal-plugin.py\n\n" + b)
open(p, 'w', newline='').write(t)
EOF
python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/fuxi-gpu.yml')); print('yaml ok')" 2>&1 | tail -1
if git diff | grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo secret; exit 1; fi
git add -A
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: optional size_opt for test builds that must fit the addon"
git -c http.extraheader="$AUTH" push -q origin HEAD:main
git log --oneline -1 | cut -c1-80
curl -fsSL -X POST "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/dispatches" -d '{"ref":"main","inputs":{"unixnu_ref":"da3736a71dfedc8b07ccebc596c9249763b3da88","build_kernel":"false","loose_submodules":"true","size_opt":"true"}}' && echo dispatched
sleep 12
curl -fsSL "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/runs?per_page=1" | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])' | tee /tmp/ci-run-id.txt
tr -d '\r' < $E/dump/wsl/wait-ci.sh > /tmp/wci.sh
bash /tmp/wci.sh "$(cut -d' ' -f1 /tmp/ci-run-id.txt)"
