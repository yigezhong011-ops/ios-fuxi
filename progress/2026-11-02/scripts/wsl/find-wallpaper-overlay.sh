#!/bin/bash
# Public copies of the 7570 wallpaper overlay (main.caml / J120 PNGs) and of GPU client lists other ports use (read-only)
for q in 'filename:J120-Dark.png' 'filename:J120.png' '7570.iPadOS_17_Flat_Background filename:main.caml' 'NativeAdrenoMetal.clients' 'WidgetRenderer NativeAdrenoMetal'; do
    echo "### $q"
    python3 /root/fuxi/cs.py "$q" | head -15
    sleep 3
done
