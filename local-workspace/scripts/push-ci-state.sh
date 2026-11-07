#!/bin/bash
# unixnu-ci: optional display_state input, the patch that clears the display's deep flag on 21H461 in the branch plugin. Normal push; token in a header only.
# Then wait for the run, download it, and build the test image. Temp boot image only; writes no partition.
set -euo pipefail
E=/mnt/e/DSH-Fuxi; S=$E/dump/wsl; TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
R=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G; mkdir -p patches
cp /root/fuxi/m2v-deep/adrenometal-21h461-display-state.patch patches/
python3 -I - <<'EOF'
p = '.github/workflows/fuxi-gpu.yml'
t = open(p, newline='').read()
a = "      build_kernel:\n"
assert t.count(a) == 1
t = t.replace(a, "      display_state:\n        description: Clear the display's deep flag on 21H461 (patches/adrenometal-21h461-display-state.patch), for a kernel whose display refuses b3a8\n        type: boolean\n        default: false\n" + a)
b = "      - name: GPU addon\n"
assert t.count(b) == 1
t = t.replace(b, "      - name: display state patch\n        if: inputs.display_state\n        run: patch -p1 -d UniXNU/drivers/AdrenoMetal < patches/adrenometal-21h461-display-state.patch\n\n" + b)
open(p, 'w', newline='').write(t)
EOF
python3 -I -c "import yaml; yaml.safe_load(open('.github/workflows/fuxi-gpu.yml')); print('yaml ok')" 2>&1 | tail -1
if git diff | grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED'; then echo secret; exit 1; fi
git add -A
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: optional display_state patch for kernels whose display refuses b3a8"
git -c http.extraheader="$AUTH" push -q origin HEAD:main
git log --oneline -1 | cut -c1-90
curl -fsSL -X POST "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/dispatches" -d '{"ref":"main","inputs":{"unixnu_ref":"da3736a71dfedc8b07ccebc596c9249763b3da88","build_kernel":"false","loose_submodules":"true","size_opt":"true","display_state":"true"}}' && echo dispatched
sleep 15
curl -fsSL "${H[@]}" "$R/actions/workflows/fuxi-gpu.yml/runs?per_page=1" | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])' | tee /tmp/ci-run-id.txt
RUN=$(cut -d' ' -f1 /tmp/ci-run-id.txt)
tr -d '\r' < $S/wait-ci.sh > /tmp/wci.sh; bash /tmp/wci.sh "$RUN" | tee /tmp/ci-result.txt
grep -q success /tmp/ci-result.txt || { echo 'CI did not succeed'; tr -d '\r' < $S/ci-addon-fail.sh > /tmp/caf.sh; bash /tmp/caf.sh "$RUN" | tail -40 | cut -c1-200; exit 1; }
tr -d '\r' < $S/get-ci-plugin.sh > /tmp/gcp3.sh; bash /tmp/gcp3.sh "$RUN" /root/fuxi/gpu-plugin-m2v-state | tail -8
tr -d '\r' < $S/make-t50-plug.sh > /tmp/mtp3.sh
AUTO_CORES=0xf9 REJ_REPORT=1 bash /tmp/mtp3.sh /root/fuxi/gpu-plugin-m2v-state t50-auto-m2vs 2>&1 | tail -8 | cut -c1-120
