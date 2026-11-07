#!/bin/bash
# Read only: how far the branch's GPU pieces are from what our kernel was built with, and what a plugin-only build would use.
U=/root/fuxi/up-latest; A=/root/fuxi/src-adreno740; M=/root/fuxi/src-adrenometal
OLD=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16; NEW=origin/feat/metal2vulkan-963f0e64
for r in $OLD $NEW; do
  echo "== $(git -C $U log -1 --format='%h %ad' --date=short $r)"
  git -C $U ls-tree $r drivers/Adreno740 drivers/AdrenoMetal kits/AdrenoPM4 drivers/ArmCpu | awk '{print $3, $4}'
  git -C $U show $r:scripts/data/adreno-compiler-inputs.json 2>/dev/null | python3 -I -c 'import json,sys; d=json.load(sys.stdin); print("mesa", d["mesa"]["commit"][:12], "patches", len(d.get("patches",[])))'
  git -C $U ls-tree --name-only $r scripts/ | grep -E 'build-boot-runtime|build-adreno-metal-plugin|build-turnip-darwin'
done
OA=$(git -C $U ls-tree $OLD drivers/Adreno740 | awk '{print $3}'); NA=$(git -C $U ls-tree $NEW drivers/Adreno740 | awk '{print $3}')
echo; echo "== Adreno740 $OA .. $NA"; git -C $A fetch -q origin; git -C $A rev-list --count $OA..$NA 2>&1
git -C $A diff --stat $OA $NA 2>/dev/null | tail -1
echo '== interface files'
git -C $A diff --stat $OA $NA -- '*.h' '*UserClient*' '*Client*' 2>/dev/null | tail -12 | cut -c1-90
git -C $A log --format='%h %ad %s' --date=short $OA..$NA -i -E --grep='abi|user.?client|selector|ioctl|interface' 2>/dev/null | cut -c1-110 | head -16
echo; echo '== kernel-call patches in Mesa between the two'
git -C $U diff --stat $OLD $NEW -- patches/mesa | tail -4 | cut -c1-100
git -C $U ls-tree -r --name-only $NEW patches/mesa | wc -l
echo; echo '== the ios target in the branch'
git -C $U show $NEW:scripts/build-boot-runtime.py 2>/dev/null | grep -nE "def build_plugin|ios27|'ios'|target" | cut -c1-110 | head -14
git -C $U show $NEW:scripts/build-adreno-metal-plugin.py 2>/dev/null | grep -nE "ios27|ios17|choices|--target|minimum|deployment" | cut -c1-110 | head -12
git -C $U show $NEW:components.toml | grep -nE 'os_abi|ipados' | sort -u -t= -k2 | cut -c1-90 | head
echo; echo '== translator patches over 624bab3 vs the frontend we could graft'
git -C $M show origin/feat/metal2vulkan-963f0e64:bridge/NativeMetalObjects.h | wc -l
git -C $M diff --stat 7e0d3d2 origin/feat/metal2vulkan-963f0e64 -- . ':!bridge/patches' | tail -1
