#!/bin/bash
# Clone the referenced WiFi repo for reading only, and summarise it next to our build and log. Nothing from it is executed.
R=/root/fuxi/ref-wifi-kerfand
[ -d "$R/.git" ] || git clone -q https://github.com/Kerfand/UniXNU-fuxi-wifi "$R" || exit 1
cd "$R" || exit 1
echo "== repo"; git remote -v | head -1; git branch -a | cut -c1-70 | head -12
git log --format='%h %ad %an %s' --date=short | cut -c1-120 | head -30
echo "commits $(git rev-list --count HEAD)"; du -sh --exclude=.git . | cut -f1
echo "== top level"; ls -la | cut -c1-100 | head -40
echo "== wifi-related files"
git ls-files | grep -i -E 'wifi|wlan|wlfw|ath|cnss|qmi|qca|kiwi|bdwlan|amss|m3\.bin|regdb|\.md$|readme' | cut -c1-120 | head -60
echo "files $(git ls-files | wc -l)"
echo "== readmes"
for f in $(git ls-files | grep -i -E '(^|/)(readme|wifi)[^/]*\.md$' | head -5); do echo "--- $f"; cut -c1-240 "$f" | head -90; done
echo "== our tree: wifi"
ls /mnt/e/DSH-Fuxi/unixnu-build/fuxi/patches/xnu 2>/dev/null | grep -i -E 'wifi|wlan|pcie|ath|cnss' | head
grep -rl -i -E 'wlan|wifi|cnss|ath1[12]k' /mnt/e/DSH-Fuxi/unixnu-build/fuxi --include=* 2>/dev/null | cut -c1-120 | head -14
echo "== upstream at head: wifi"
for n in src-unixnu src-adreno740; do git -C /root/fuxi/$n log --format='%h %ad %s' --date=short -i -E --grep='wifi|wlan|ath1[12]k|cnss|kiwi' origin/main | cut -c1-110 | head -14; done
echo "== log"
python3 -I - <<'EOF'
import re
from collections import Counter
t = open('/mnt/e/DSH-Fuxi/logs/carve-tonight/lscan.txt', 'rb').read().replace(b'\r\n', b'\n').decode('latin1')
c = Counter(re.sub(r'\[\d+\]|0x[0-9a-f]+', '#', x)[:190] for x in re.findall(r'[^\n]*(?:wifid|WiFiManager|WiFiDevice|com\.apple\.wifi|corewifi|AppleBCMWLAN|IO80211|wlan0|\ben0\b)[^\n]*', t))
print('hits', sum(c.values()))
for k, v in c.most_common(25):
    print(f'{v:5d} {k}')
EOF
for f in /root/fuxi/log-oslog1/*/msgbuf.txt; do echo "-- msgbuf"; tr -d '\000' < "$f" | grep -a -i -E 'wifi|wlan|80211|bcm|ath1|cnss' | cut -c1-170 | tail -14; done
