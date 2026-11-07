#!/bin/bash
# Add the plugin patch to the owner's unixnu-ci repository, teach the workflow an optional plugin_patch input, dispatch a plugin-only build.
# The token stays in a header, never in a URL or a remote. Normal push only.
set -uo pipefail
E=/mnt/e/DSH-Fuxi
cd /root/fuxi/plugin-try
git status -s | head -5; git log --oneline -3 | cut -c1-80
git diff 7e0d3d2 HEAD > /root/fuxi/plugin-poster.patch; wc -l /root/fuxi/plugin-poster.patch
git diff --stat 7e0d3d2 HEAD | tail -7 | cut -c1-90
set -e
TOKEN=$(tr -d '\r\n ' < $E/token2.txt)
AUTH="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$TOKEN" | base64 -w0)"
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')
G=/root/fuxi/unixnu-ci-push; rm -rf $G
git -c http.extraheader="$AUTH" clone -q --depth 5 https://github.com/yigezhong011-ops/unixnu-ci.git $G
cd $G
sed -n 9,34p .github/workflows/fuxi-gpu.yml | cut -c1-110
cp /root/fuxi/plugin-poster.patch ci/patches/adrenometal-poster-7e0d3d2.patch
python3 -I - <<'EOF'
p = '.github/workflows/fuxi-gpu.yml'
t = open(p, newline='').read()
if 'plugin_patch' not in t:
    a = "      build_kernel:\n"
    assert t.count(a) == 1
    t = t.replace(a, "      plugin_patch:\n        description: file in ci/patches to apply to drivers/AdrenoMetal before the build; empty for none\n        required: false\n        default: ''\n" + a)
    b = "      - name: GPU addon\n"
    assert t.count(b) == 1
    t = t.replace(b, "      - name: plugin patch\n        if: inputs.plugin_patch != ''\n        run: git -C UniXNU/drivers/AdrenoMetal apply --whitespace=nowarn \"$GITHUB_WORKSPACE/ci-self/ci/patches/${{ inputs.plugin_patch }}\"\n\n" + b)
    open(p, 'w', newline='').write(t)
EOF
if grep -E 'ghp_[A-Za-z0-9]{20,}|github_pat_|AGE-SECRET-KEY|UNIQUE_CHIP_ID_REDACTED|FASTBOOT_SERIAL_REDACTED' ci/patches/adrenometal-poster-7e0d3d2.patch .github/workflows/fuxi-gpu.yml; then echo secret; exit 1; fi
git add -A; git diff --cached --stat | tail -3 | cut -c1-90
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m "ci: optional plugin patch; Poster fixes for AdrenoMetal 7e0d3d2

8c1ea13 completes resource interfaces and renders Poster with one sample, and 5a50581 does the same for all clients. Both are upstream's, resolved onto our pin."
git -c http.extraheader="$AUTH" push -q origin HEAD:main
git log --oneline -1 | cut -c1-80
F=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
curl -fsSL -X POST "${H[@]}" https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/dispatches -d "{\"ref\":\"main\",\"inputs\":{\"unixnu_ref\":\"$F\",\"build_kernel\":\"false\",\"plugin_patch\":\"adrenometal-poster-7e0d3d2.patch\"}}" && echo dispatched
sleep 10
curl -fsSL "${H[@]}" 'https://api.github.com/repos/yigezhong011-ops/unixnu-ci/actions/workflows/fuxi-gpu.yml/runs?per_page=1' | python3 -I -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"][0]; print(r["id"], r["status"], r["head_sha"][:7], r["created_at"])'
