#!/bin/bash
# Wallpaper assets per idiom from the stored file list, and the code around the store failure. Read-only.
E=/mnt/e/DSH-Fuxi; P=$E/dump/root-peek; S=$E/dump/wsl; D=$P/dsc
head -6 $P/list.txt | cut -c1-120
echo "== wallpaper collections"
grep -a -o -E 'Wallpaper/Collections/[^/ ]+' $P/list.txt | sort | uniq -c | sort -rn | head -14
echo "== wallpaper bundles by suffix"
grep -a -o -E '[^/ ]+\.wallpaper(/|$| )' $P/list.txt | sed -E 's/[\/ ]$//' | sort -u > /root/fuxi/wall-names.txt
wc -l < /root/fuxi/wall-names.txt
grep -c '~ipad' /root/fuxi/wall-names.txt; grep -c '~iphone' /root/fuxi/wall-names.txt; grep -v -E '~ipad|~iphone' /root/fuxi/wall-names.txt | head -12 | cut -c1-90
echo "== poster extensions"
grep -a -o -E '[A-Za-z]*Poster[A-Za-z]*\.appex' $P/list.txt | sort | uniq -c | sort -rn | head -24
echo "== any ~iphone .ca wallpaper"
grep -a -E '~iphone[^ ]*\.(ca|wallpaper)' $P/list.txt | head -6 | cut -c1-170
echo "== store failure xrefs"
cd $S
python3 -I read-dsc-xref.py $D x 'Data store could not be created for an unknown reason which evades explanation.' 'Unable to setup dataStore URL' 'Datastore could not be loaded' 'Data store migration finished' 2>&1 | cut -c1-170 | head -30
