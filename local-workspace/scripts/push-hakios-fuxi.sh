#!/bin/bash
# Push the HakiOS kernel tree with the generated fuxi device to our own repository so
# a macOS runner can build it.
set -uo pipefail
TOKEN=$(tr -d '\r\n' < /mnt/e/DSH-Fuxi/token2.txt)
REPO=hakios-fuxi
SRC=/root/hakios-xnu-kernel

cd "$SRC" || exit 1
echo "=== 现有仓库状态 ==="
git log --oneline -1 | cut -c1-90
git status --short | head -5

mkdir -p .github/workflows
cat > .github/workflows/build.yml <<'YAML'
name: build fuxi kernel

on:
  workflow_dispatch:
    inputs:
      defconfig:
        description: defconfig name
        required: true
        default: fuxi_defconfig
      target:
        description: make target
        required: true
        default: kernel

permissions:
  contents: read

jobs:
  build:
    runs-on: macos-26
    timeout-minutes: 180
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: false
      - name: Select Xcode
        run: |
          ls /Applications | grep -i xcode || true
          sudo xcode-select -s /Applications/Xcode_26.6.app/Contents/Developer 2>/dev/null || \
          sudo xcode-select -s "$(ls -d /Applications/Xcode*.app | head -1)/Contents/Developer"
          xcodebuild -version
      - name: Host tools
        run: brew install lld llvm dtc 2>/dev/null || true
      - name: Configure
        run: |
          make "${{ inputs.defconfig }}"
          make config
      - name: Build
        run: make "${{ inputs.target }}" 2>&1 | tail -120
      - name: Collect
        if: always()
        run: |
          ls -l hakios-kernel 2>/dev/null || true
          mkdir -p out
          cp hakios-kernel out/ 2>/dev/null || true
          cp -r xnu-src/xnu-*/BUILD/obj/DEVELOPMENT_ARM64_BCM2837/mach.development.bcm2837 out/ 2>/dev/null || true
      - name: Upload kernel
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: hakios-kernel
          path: out/
          if-no-files-found: warn
          retention-days: 7
      - name: Logs
        if: always()
        run: |
          mkdir -p logs
          cp -r xnu-deps/*.log logs/ 2>/dev/null || true
          tail -200 nohup.out >> logs/build-tail.log 2>/dev/null || true
      - name: Upload logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: hakios-logs
          path: logs/
          if-no-files-found: warn
          retention-days: 7
YAML

git -c user.name=dsh -c user.email=dsh@local add devices/fuxi .github/workflows/build.yml 2>/dev/null
git -c user.name=dsh -c user.email=dsh@local commit -qm "fuxi: device repository from its own device tree, plus a macOS build workflow" 2>&1 | tail -2

git remote remove ci 2>/dev/null || true
git remote add ci "https://x-access-token:${TOKEN}@github.com/yigezhong011-ops/${REPO}.git"
echo "=== 推送（36 MB，可能较慢）==="
git push -q -f ci HEAD:main && echo "已推送" || echo "推送失败"
git log --oneline -1 | cut -c1-90
