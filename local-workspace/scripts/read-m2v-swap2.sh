#!/bin/bash
# Read only: our display driver version against the commits that matter, what a refused surface leaves behind, and what the branch plugin says about scanout formats.
G=/root/fuxi/ref-gopfb; A=/root/fuxi/src-adrenometal; U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64; K=/root/fuxi/t50-gpu7/kernel.macho
git -C $G cat-file -e 74ff4c4 2>/dev/null && echo 'have 74ff4c4' || echo 'no 74ff4c4 here'
git -C $G log -1 --format='%h %ad %s' --date=short 74ff4c4 | cut -c1-100
for c in 35ce1b7 33e941a bf854d2 cb4459b df4a905; do git -C $G merge-base --is-ancestor $c 74ff4c4 && echo "$c in ours" || echo "$c NOT in ours"; done
echo; echo '== format and refused surface at our version'
git -C $G grep -n -E 'nativeScanoutFormat|native_legacy_surface_rejected|native_legacy_swap_validation_observed|verify_swap' 74ff4c4 | sed 's#^74ff4c4:##' | cut -c1-190 | head -14
for f in native_legacy_surface_rejected native_legacy_swap_validation_observed; do
  F=$(git -C $G grep -l "void $f" 74ff4c4 | sed 's#^74ff4c4:##' | head -1); echo "-- $f in $F"
  [ -n "$F" ] && git -C $G show 74ff4c4:"$F" | grep -n -A12 "void $f" | head -22 | cut -c1-170
done
F=$(git -C $G grep -l 'nativeScanoutFormat' 74ff4c4 | sed 's#^74ff4c4:##' | head -1)
git -C $G show 74ff4c4:"$F" | grep -n -B1 -A8 'nativeScanoutFormat(' | head -24 | cut -c1-150
echo; echo '== symbols in our kernel'
llvm-nm --defined-only $K 2>/dev/null | grep -E 'native_legacy_(surface_rejected|swap_validation|rejected|last)|native_legacy_.*(reject|reason)' | head -20
echo; echo '== plugin: formats and scanout words between our base and the branch'
git -C $A cat-file -e ce63701 2>/dev/null && echo have-ce63701
git -C $A log -1 --format='%h %ad %s' --date=short 7e0d3d2 2>/dev/null | cut -c1-90; git -C $A log --oneline 7e0d3d2..ce63701 2>/dev/null | wc -l
git -C $A log --format='%h %ad %s' --date=short 7e0d3d2..ce63701 2>/dev/null | grep -iE 'scanout|format|bgra|rgba|half|float|wide|xr|p3|colou?r|iosurface|layer|drawable|display|compressed|gamut|device' | cut -c1-115 | head -30
echo; echo '== branch docs: scanout format, wide colour, half float, display requirement'
git -C $U grep -n -iE 'half-?float|rgba16|bgr10|wide.?colou?r|extended range|bgra10|scanout format' $B -- docs/porting docs/drivers drivers/AdrenoMetal 2>/dev/null ':!docs/zh' | sed "s#^$B:##" | cut -c1-260 | head -16
git -C $U show $B:docs/devices/sirius-dddqmmx.md | sed -n 321p | cut -c1-700
