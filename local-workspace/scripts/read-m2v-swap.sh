#!/bin/bash
# Read only: what the branch changes about the swap check, and what our kernel's check needs.
U=/root/fuxi/up-latest; B=origin/feat/metal2vulkan-963f0e64; Pin=/root/fuxi/unixnu-pin; G=/root/fuxi/ref-gopfb
git -C $U fetch -q origin 2>/dev/null || true
echo '== docs and tree on the branch'
git -C $U grep -n -iE 'verify_swap|validateSwap|validate_swap' $B -- . ':!docs/zh' | sed "s#^$B:##" | cut -c1-230 | head -20
echo; echo '== driver pins, ours and the branch'
for t in $B; do git -C $U ls-tree $t drivers/ | grep -iE 'Gop|Adreno|Legacy|Display|Framebuffer' | cut -c8-; done
echo '-- ours'; git -C $Pin ls-tree HEAD drivers/ 2>/dev/null | grep -iE 'Gop|Adreno|Legacy|Display|Framebuffer' | cut -c8-
echo; echo '== GopFramebuffer log'; git -C $G log --format='%h %ad %s' --date=short -25 | cut -c1-110
echo; echo '== check in GopFramebuffer now'
git -C $G grep -n -E 'verify_swap|validateSwap|reason' HEAD | sed 's#^HEAD:##' | cut -c1-170 | head -30
echo; F=$(git -C $G grep -l 'validateSwap' HEAD | sed 's#^HEAD:##' | grep -E '\.(cpp|mm|c)$' | head -1); echo "file $F"
n=$(git -C $G show HEAD:"$F" | grep -n 'validateSwap' | head -1 | cut -d: -f1); [ -n "$n" ] && git -C $G show HEAD:"$F" | sed -n "$n,$((n+70))p" | cut -c1-120
echo; echo '== branch commits on the plugin and Adreno that speak about surfaces, formats or swaps'
A=/root/fuxi/src-adrenometal; git -C $A fetch -q origin 2>/dev/null || true
git -C $A log --format='%h %s' 243d63c..ce63701 2>/dev/null | grep -iE 'surface|swap|scanout|format|ubwc|tile|layer|display|present|drawable|iosurface' | cut -c1-110 | head -30
echo "-- commits in all: $(git -C $A log --oneline 243d63c..ce63701 2>/dev/null | wc -l)"
