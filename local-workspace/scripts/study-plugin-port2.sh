#!/bin/bash
# Read-only for the repositories upstream: show the conflicts of 8c1ea13 and 5a50581 on our pin, and how our CI picks the plugin.
cd /root/fuxi/plugin-try; git cherry-pick --abort 2>/dev/null; git reset -q --hard 7e0d3d2
git -c user.name=x -c user.email=x@x cherry-pick -x 8c1ea13 >/dev/null 2>&1
git diff --name-only --diff-filter=U
git diff | cut -c1-170 | head -90
git cherry-pick --abort
echo "== CI"; ls /root/fuxi/unixnu-ci /root/fuxi/uni-oldci 2>/dev/null | head -12
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
curl -fsSL -H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github.raw' "https://api.github.com/repos/yigezhong011-ops/unixnu-ci/contents/.github/workflows/fuxi-gpu.yml" -o /root/fuxi/fuxi-gpu.yml; wc -l /root/fuxi/fuxi-gpu.yml
grep -n -E 'inputs:|unixnu_ref|build_kernel|AdrenoMetal|adreno_metal|git (clone|fetch|checkout|apply)|patch|submodule|upload-artifact|age |name: ' /root/fuxi/fuxi-gpu.yml | cut -c1-150 | head -70
cat /root/fuxi/gpu-new-t50-mine/revisions.txt | cut -c1-120
