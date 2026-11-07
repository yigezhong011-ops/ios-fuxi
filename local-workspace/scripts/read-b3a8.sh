#!/bin/bash
# Read only: who speaks of the b3a8 format and two-plane scanout, in the plugin, the driver and every doc on the branch; and which device answers differ.
A=/root/fuxi/src-adrenometal; U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64; T=ce63701; G=/root/fuxi/ref-gopfb; P=/root/fuxi/plugin-try
P_HEAD=$(git -C $P rev-parse --short HEAD)
PAT='b3a8|62336138|0x62336138|bgr3|alpha plane|two-?plane|biplanar|bi-planar|planar IOSurface|CA_|QuartzCore|backboardd|compositor'
echo '== docs on the branch'
git -C $U grep -n -iE 'b3a8|62336138|bgr.{0,10}alpha plane' $B -- docs ':!docs/zh' | sed "s#^$B:##" | cut -c1-320 | head -14
echo; echo '== plugin at the branch: format words'
git -C $A grep -n -iE 'b3a8|62336138' $T | sed "s#^$T:##" | cut -c1-210 | head -20
echo; echo '== display driver at the branch'; git -C $G grep -n -iE 'b3a8|62336138' HEAD | cut -c1-200 | head
echo; echo '== plugin diff, our build against the branch: files changed'
git -C $A diff --stat $P_HEAD $T 2>/dev/null | tail -30 | cut -c1-90
echo; echo '== added or removed lines naming formats, surfaces or the compositor'
git -C $A diff $P_HEAD $T -- . 2>/dev/null | grep -E '^[+-]' | grep -iE "$PAT|supportsFamily|GPUFamily|featureSet|deviceAnswer|answer|isDepth24|lossy|compress|readWriteTexture|wideColor|sparse" | grep -vE '^(\+\+\+|---)' | cut -c1-170 | head -60
echo; echo '== commit messages since our build on these words'
git -C $A log --format='%h %ad %s' --date=short $P_HEAD..$T 2>/dev/null | cut -c1-120 | head -20
echo; git -C $A log --format='%h %s' $T -i -E --grep='answer|family|compositor|backboard|surface|plane' -14 | cut -c1-110
