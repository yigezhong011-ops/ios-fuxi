#!/bin/bash
# The CI repo's current macos.yml upload steps, its divergence from upstream, and the fuxi fork's branches.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
mkdir -p /root/fuxi/ci; cd /root/fuxi/ci
curl -fsSL -H "Authorization: Bearer $TOKEN" https://raw.githubusercontent.com/yigezhong011-ops/unixnu-ci/main/.github/workflows/macos.yml -o macos.yml
grep -n -A16 'Upload the built kernel' macos.yml | head -50
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$1"; }
echo "### unixnu-ci vs UniXNU/UniXNU main"
api 'UniXNU/UniXNU/compare/main...yigezhong011-ops:unixnu-ci:main' | python3 -c 'import json,sys; c=json.load(sys.stdin); print(c["status"], "ahead", c["ahead_by"], "behind", c["behind_by"]); [print("  ", x["sha"][:9], x["commit"]["message"].splitlines()[0][:90]) for x in c["commits"][-8:]]'
echo "### yigezhong011-ops/unixnu-fuxi branches"
api 'yigezhong011-ops/unixnu-fuxi/branches' | python3 -c 'import json,sys; [print("  ", b["name"], b["commit"]["sha"][:9]) for b in json.load(sys.stdin)]'
echo "### artifacts of the 11-01 run"
api 'yigezhong011-ops/unixnu-ci/actions/runs/41294613121/artifacts' | python3 -c 'import json,sys; [print("  ", a["name"], a["size_in_bytes"], a["expired"]) for a in json.load(sys.stdin)["artifacts"]]'
