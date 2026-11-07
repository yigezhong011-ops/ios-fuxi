#!/bin/bash
# Put the UniXNU fork in our account and add a kernel-only workflow.
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
REPO=fuxi-touch-ci
cd /root/uni-odd || exit 1

mkdir -p .github/workflows
cat > .github/workflows/kernel.yml <<'YAML'
name: build fuxi touch kernel

on:
  workflow_dispatch:
    inputs:
      defconfig:
        default: fuxi_defconfig
      device_repository:
        default: yigezhong011-ops/fuxi-touch
      device_ref:
        default: main

permissions:
  contents: read

jobs:
  kernel:
    runs-on: macos-26
    timeout-minutes: 180
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      - name: Check out the device repository
        run: |
          git clone --depth 1 --recurse-submodules --branch "${{ inputs.device_ref }}" \
            "https://github.com/${{ inputs.device_repository }}.git" ../device
      - name: Host tools
        run: brew install dtc llvm lld 2>/dev/null || true
      - name: Configure
        run: |
          ./unixnu defconfig "${{ inputs.defconfig }}" -D ../device
      - name: Build kernel
        run: |
          set -o pipefail
          ./unixnu build kernel -D ../device 2>&1 | tail -60
      - name: Collect
        if: always()
        run: |
          mkdir -p out
          find out -name 'kernel.macho' -exec cp {} out/ \; 2>/dev/null || true
          find out -name 'kernel.json' -exec cp {} out/ \; 2>/dev/null || true
          ls -l out || true
      - name: Upload kernel
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: fuxi-touch-kernel
          path: out/
          if-no-files-found: warn
          retention-days: 7
      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: fuxi-touch-logs
          path: |
            out/**/logs/*.log
          if-no-files-found: warn
          retention-days: 7
YAML

echo "=== 树 ==="
git log --oneline -1 | cut -c1-90
git config user.name dsh
git config user.email dsh@local
git add .github/workflows/kernel.yml
git -c user.name=dsh -c user.email=dsh@local commit -qm "ci: build the fuxi kernel" 2>/dev/null || echo "（无改动）"

python3 - "$TOKEN" "$REPO" <<'PY'
import json, sys, urllib.request
token, name = sys.argv[1], sys.argv[2]
H = {'Authorization': f'Bearer {token}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json',
     'Content-Type': 'application/json'}
body = json.dumps({'name': name, 'private': False,
                   'description': 'UniXNU fork with the fuxi FTS touch component'}).encode()
req = urllib.request.Request('https://api.github.com/user/repos', data=body, headers=H, method='POST')
try:
    r = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
    print('已建仓库:', r['full_name'])
except urllib.error.HTTPError as e:
    print('建仓库:', e.code, e.read().decode()[:120])
PY

git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/${REPO}.git"
echo "=== 推送（27 MB）==="
git push -q -f ci HEAD:main && echo "已推送" || echo "推送失败"
