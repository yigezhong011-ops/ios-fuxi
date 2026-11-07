#!/bin/bash
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
cd $S
python3 -I read-dsc-xref.py $D d 0x1ca915384 120 1d0 0x1ca9149c8 200 40 > /root/fuxi/glue.txt 2>&1
wc -l /root/fuxi/glue.txt; tail -2 /root/fuxi/glue.txt | cut -c1-200
grep -E ' ; |^==|cbz|cbnz|tbz|tbnz|ret' /root/fuxi/glue.txt | cut -c1-130
echo "== run()"
cd /root/fuxi/src-adrenometal
grep -n 'static.* run(' CacheExport.h
awk '/static void run\(|void run\(/{p=1} p{print} ' CacheExport.h | cut -c1-165 | head -55
sed -n 47,58p NativeAdrenoMetalPlugin.mm | cut -c1-150
echo "== markers in last boot"
grep -a -n -E '69f[0-9a-f]|0x69|mark' /root/fuxi/log-oslog1/*/latest.txt | cut -c1-150 | head
