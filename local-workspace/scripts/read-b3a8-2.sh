#!/bin/bash
# Read only: what decides between b3a8 and a plain frame. Words in both plugin trees, the docs on the compositor's frame format, and the changes near them.
A=/root/fuxi/src-adrenometal; U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64; T=ce63701; P=/root/fuxi/plugin-try
OLD=$(git -C $P rev-parse --short HEAD)
W='deep|ExtendedRange|extended.range|wide.?gamut|wide.?colou?r|XR10|RGhA|52476841|half-?float|supportsExtended|displayGamut|colorSpace|frameFormat|framebuffer format|CA_DEEP|deep_|isDeep|BGR10|RGB10A8|bgra8|prefers'
for t in $OLD $T; do
  echo "== $t bridge and frontend, non-patch sources"
  git -C $A grep -n -iE "$W" $t -- '*.mm' '*.m' '*.cpp' '*.h' '*.py' '*.md' ':!bridge/patches' 2>/dev/null | sed "s#^$t:##" | cut -c1-200 | head -28
done
echo; echo '== lines that changed with these words'
git -C $A diff $OLD $T -- '*.mm' '*.m' '*.cpp' '*.h' '*.plist' 2>/dev/null | grep -E '^[+-]' | grep -iE "$W|sheng-|bootArg|gpucomp|interpose|DYLD_|hook" | grep -vE '^(\+\+\+|---)' | cut -c1-190 | head -40
echo; echo '== docs: who picks the frame format'
git -C $U grep -n -iE "(b3a8|two-plane|RGB10A8|half-?float|RGhA).{0,120}(compositor|backboardd|QuartzCore|picks|chooses|because|when)|(compositor|backboardd|QuartzCore).{0,120}(b3a8|two-plane|RGB10A8|half-?float|RGhA|BGRA)" $B -- docs/porting docs/drivers docs/devices ':!docs/zh' | sed "s#^$B:##" | cut -c1-360 | head -18
echo; echo '== uke record lines near the switch'
git -C $U show $B:docs/.vitepress/device-records/uke.toml | grep -n -iE 'b3a8|half|bgra|format' | cut -c1-300 | head -14
echo; echo '== entries that differ between the two plugin builds other than the two big binaries'
ls /root/fuxi/gpu-plugin-m2v-small /root/fuxi/gpu-plugin-1105 | head -24
