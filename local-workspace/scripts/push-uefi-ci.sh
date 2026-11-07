#!/bin/bash
# Push the HakiOS-patched fuxi UEFI tree so a macOS runner can build the firmware
# image (the Linux path fails on a NuGet dependency).
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
cd /root/uefi-hak-fuxi || exit 1

mkdir -p .github/workflows
cat > .github/workflows/uefi.yml <<'YAML'
name: build fuxi uefi

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  uefi:
    runs-on: macos-26
    timeout-minutes: 120
    steps:
      - uses: actions/checkout@v4
      - name: Python deps
        run: python3 -m pip install -r pip-requirements.txt
      - name: Build
        run: |
          python3 build_uefi.py -d fuxi -r RELEASE 2>&1 | tail -60
      - name: Collect
        if: always()
        run: |
          mkdir -p out
          find Build -name 'SILICIUM_UEFI.fd' -exec cp {} out/ \; 2>/dev/null || true
          find Build -name '*.fd' -exec cp {} out/ \; 2>/dev/null || true
          ls -l out || true
      - name: Upload
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: fuxi-uefi
          path: out/
          if-no-files-found: warn
          retention-days: 7
YAML

echo "=== 大小 ==="
du -sh . 2>/dev/null
git config user.name dsh
git config user.email dsh@local
git checkout -q --orphan ci-main 2>/dev/null || git checkout -q ci-main
git add -A 2>&1 | tail -2
git commit -qm "HakiOS loader on the fuxi Mu-Silicium platform" 2>&1 | tail -2
git count-objects -vH | grep size-pack

python3 - <<'PY'
import json, pathlib, urllib.request
TOKEN = pathlib.Path('/mnt/e/DSH-Fuxi/token2.txt').read_text().strip()
H = {'Authorization': f'Bearer {TOKEN}', 'User-Agent': 'dsh', 'Accept': 'application/vnd.github+json',
     'Content-Type': 'application/json'}
body = json.dumps({'name': 'hakios-uefi-fuxi', 'private': False,
                   'description': 'HakiOS UEFI loader for the Xiaomi 13 (fuxi)'}).encode()
req = urllib.request.Request('https://api.github.com/user/repos', data=body, headers=H, method='POST')
try:
    r = json.loads(urllib.request.urlopen(req, timeout=60).read().decode())
    print('已建仓库:', r['full_name'])
except urllib.error.HTTPError as e:
    print('建仓库:', e.code, e.read().decode()[:150])
PY

git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/hakios-uefi-fuxi.git"
echo "=== 推送（可能较慢）==="
git push -q -f ci ci-main:main && echo "已推送" || echo "推送失败"
