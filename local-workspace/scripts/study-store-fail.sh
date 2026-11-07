#!/bin/bash
# Why does the poster data store fail, and has upstream met the HEVC encode or clock problems? Read-only.
U=/root/fuxi/src-unixnu; M=/root/fuxi/src-adrenometal; A=/root/fuxi/src-adreno740
PAT='hvc1|heic|HEIC|hevc|HEVC|VTCompression|AppleAVE|AVE2|CMPhoto|ChronoKit|chronod|WidgetRenderer|PosterBoard|PBFPoster|dataStore|settimeofday|real.?time.?clock|\bRTC\b|\brtc\b|1969'
for r in src-unixnu:793d6bddf7 src-adrenometal:7e0d3d2 src-adreno740:759d646; do
  n=${r%%:*}; p=${r##*:}; G=/root/fuxi/$n
  echo "=== $n: commits since our pin that mention these"
  git -C $G log --format='%h %ad %s' --date=short -i -E --grep='hvc1|heic|hevc|videotoolbox|encoder|chrono|widget|poster|data ?store|rtc|clock|wall.?clock|time of day|1969' $p..origin/main | cut -c1-125 | head -30
  echo "=== $n: tree at head"
  git -C $G grep -n -I -E "$PAT" origin/main -- . ':!*.json' ':!*.txt' 2>/dev/null | sed 's/^origin\/main://' | cut -c1-175 | head -30
done
echo "=== build tree"
grep -rn -I -E 'settimeofday|\brtc\b|\bRTC\b|hvc1|VTCompression|AppleAVE' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/patches /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package 2>/dev/null | cut -c1-170 | head -16
echo "=== log: poster lines near the failure, and clock lines"
python3 -I - <<'EOF'
import re
from collections import Counter
text = open('/mnt/e/DSH-Fuxi/logs/carve-tonight/lscan.txt', 'rb').read().replace(b'\r\n', b'\n').decode('latin1')
near = Counter()
for m in re.finditer(r'"Data store could not be created', text):
    seg = text[max(0, m.start() - 9000):m.start() + 5000]
    for l in seg.split('\n'):
        if re.search(r'(?i)poster|PBF|PRB|PRS|gallery|descriptor|store|migrat|reap|language|sandbox|container|permission|denied', l):
            near[re.sub(r'0x[0-9a-f]+|[0-9A-F]{8}-[0-9A-F-]{27}', '#', l)[:230]] += 1
for k, v in near.most_common(45):
    print(f'{v:4d} {k}')
print('-- PRBPosterExtensionDataStore paths')
c = Counter(re.sub(r'[0-9A-F]{8}-[0-9A-F-]{27}', '#', x)[:170] for x in re.findall(r'[^\n]*PRBPosterExtensionDataStore[^\n]*', text))
for k, v in c.most_common(14):
    print(f'{v:4d} {k}')
print('-- clock')
c = Counter(re.sub(r'\d', '#', x)[:150] for x in re.findall(r'[^\n]*(?:system clock|timed|TMSetAutomaticTime|time zone|settimeofday|Time is not|clock is|RTC)[^\n]*', text))
for k, v in c.most_common(12):
    print(f'{v:4d} {k}')
print('-- crash report names by year')
print(Counter(x[:4] for x in re.findall(r'-(\d{4})-\d\d-\d\d-\d{6}', text)).most_common(6))
print('-- crash report processes')
print(Counter(re.findall(r'Logs/CrashReporter/([A-Za-z_]+?)-\d{4}-', text)).most_common(25))
EOF
echo "=== PosterBoard error site in the dyld cache"
sed -n '1,30p' /mnt/e/DSH-Fuxi/dump/wsl/run-dsc-xref.sh 2>/dev/null | cut -c1-150
ls /mnt/e/DSH-Fuxi/dump/wsl/ | grep -E 'run-dsc|read-dsc'
sed -n '1,14p' /mnt/e/DSH-Fuxi/dump/wsl/read-dsc-xref.py | cut -c1-160
