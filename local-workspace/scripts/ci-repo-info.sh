#!/bin/bash
# Visibility, workflows and secrets names of the user's CI repository (read-only).
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
api() { curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/yigezhong011-ops/unixnu-ci$1"; }
api '' | python3 -c 'import json,sys; r=json.load(sys.stdin); print("private:", r["private"], "fork of:", (r.get("parent") or {}).get("full_name"), "default:", r["default_branch"], "pushed:", r["pushed_at"])'
api '/actions/workflows' | python3 -c 'import json,sys; [print("wf:", w["path"], w["state"]) for w in json.load(sys.stdin)["workflows"]]'
api '/actions/secrets' | python3 -c 'import json,sys; [print("secret:", s["name"]) for s in json.load(sys.stdin)["secrets"]]' 2>&1 | head
api '/actions/runs?per_page=5' | python3 -c 'import json,sys; [print("run:", r["name"], r["status"], r["conclusion"], r["created_at"][:16]) for r in json.load(sys.stdin)["workflow_runs"]]'
