#!/bin/bash
# Read only: what our plugin pin has compared with the new branch, for the black wallpapers and thumbnails.
A=/root/fuxi/src-adrenometal; B=origin/feat/metal2vulkan-963f0e64; M=origin/main; P=7e0d3d2
for r in $P $M $B; do
  echo "== $r $(git -C $A log -1 --format='%h %ad' --date=short $r)"
  git -C $A grep -nE 'pipeline_waits|PipelineWaitPolicy|render_lowering|commit_and_submit|refuse_rebinds' $r -- bridge/NativeMetalObjects.rs | sed "s#^$r:##" | cut -c1-130
done
echo; echo '== when Exact came in'
git -C $A log --format='%h %ad %s' --date=short -S'PipelineWaitPolicy::Exact' -- bridge/NativeMetalObjects.rs | cut -c1-120
c=$(git -C $A log --format=%h -S'PipelineWaitPolicy::Exact' -- bridge/NativeMetalObjects.rs | tail -1); [ -n "$c" ] && git -C $A log -1 --format=%B $c | cut -c1-200
echo; echo '== frontend and kernel calls new in the branch over our pin'
git -C $A diff --stat $P $B -- NativeBridgeMetalFrontend.mm bridge/NativeMetalObjects.h | tail -3
git -C $A diff $P $B -- . ':!bridge/patches' | grep -iE '^\+.*(poster|sandbox|snapshot|function.?constant|MetalView|IOSurface.*(bgr|format))' | cut -c1-150 | head -20
echo; echo '== commits since our pin that mention these'
git -C $A log --format='%h %ad %s' --date=short $P..$B -i -E --grep='poster|wallpaper|black|sandbox|snapshot|function constant|specializ' | cut -c1-120 | head -25
echo; echo '== UniXNU-sheng records: wallpaper / poster'
grep -n -iE 'poster|wallpaper|black' /mnt/e/DSH-Fuxi/logs/m2v-read/device-fuxi.md /mnt/e/DSH-Fuxi/logs/m2v-read/porting-gpu.md | cut -c1-230 | head -24
echo; echo '== build inputs needed by the CI plugin job'
grep -nE 'plugin_ref|plugin_patch|adrenometal|AdrenoMetal|inputs:|runs-on' /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml 2>/dev/null | cut -c1-130 | head -24
