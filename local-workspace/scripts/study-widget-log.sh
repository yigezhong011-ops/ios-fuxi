#!/bin/bash
# Read-only: the last boot's decoded log around encoding, widgets and posters. Long fields are cut.
L=/root/fuxi/wall1/new.txt
wc -l $L
head -3 $L | cut -c1-200
for p in 'hvc1' '12782' 'unableToFinalizeImageDestination' 'initialReloadFailureRetry' 'WALLPAPER' 'AegirPoster' 'CollectionsPoster' 'KaleidoscopePoster' 'EmojiPoster' 'PhotosPoster' 'GradientPoster' 'UnityPoster' 'WeatherPoster' 'PosterBoard' 'HEIC' 'public.heic' 'AppleAVD' 'AVE' 'VTDecoder' 'VTCompression' 'CGImageDestination' 'ImageIO' 'CMPhoto'; do printf '%-36s %s\n' "$p" "$(grep -c -- "$p" $L)"; done
echo "== hvc1"; grep -n -- 'hvc1\|12782' $L | head -8 | cut -c1-320
echo "== finalize"; grep -n 'unableToFinalizeImageDestination' $L | head -5 | cut -c1-500
echo "== senders of finalize"; grep 'unableToFinalizeImageDestination' $L | awk '{print $3,$4,$5}' | sort | uniq -c | sort -rn | head -8
echo "== WALLPAPER"; grep -n 'WALLPAPER' $L | head -6 | cut -c1-200
echo "== encoder words"; grep -n -E 'VTCompression|VTEncoder|CGImageDestination|CMPhoto' $L | head -12 | cut -c1-320
echo "== process list with poster"; grep -i -E 'Poster' $L | grep -v -E 'PosterBoard|com.apple.PosterKit' | head -12 | cut -c1-260
