#!/bin/bash
# Read-only: what upstream's docs and code say about widgets, HEVC encoding and the wallpaper store; then the last boot's log around the widget errors.
U=/root/fuxi/up-latest
cd $U; git log -1 --format='%h %ad' --date=short
echo "== docs: hevc / encoder"
grep -rIl -i -E 'hvc1|hevc|12782|VideoToolbox|AppleAVE|AVE2|H\.?265|heic' docs 2>/dev/null | head -20
grep -rIn -i -E 'hvc1|12782|unableToFinalize|AppleAVE|heic' docs 2>/dev/null | cut -c1-200 | head -20
echo "== docs: widget / poster"
grep -rIn -i -E 'widget|chronod|PosterBoard|PRBPoster|wallpaper|壁纸|小组件' docs 2>/dev/null | cut -c1-200 | head -40
echo "== code: hevc / encoder"
grep -rIl -i -E 'hvc1|12782|AppleAVE|VTCompressionSession|encoder' --include='*' drivers scripts kits src 2>/dev/null | grep -v -E '/(third_party|vendor|node_modules)/' | head -20
echo "== all device-record commits touching these"
git log --oneline -i --grep='widget\|poster\|wallpaper\|hevc\|encoder' 2>/dev/null | cut -c1-110 | head -20
echo "== log"
L=$(ls -t /root/fuxi/wall*/log*.txt /root/fuxi/wall*/*/*.txt 2>/dev/null | head -5); echo "$L"
