#!/bin/bash
# Staged system apps, and where the shared cache lives in the image's windows. The image is only read.
I=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
W=/mnt/e/DSH-Fuxi/dump/root-peek
python3 - <<'EOF'
import json
j=json.load(open('/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.json'))
for w in j.get('windows',[]): print(w['name'],w['offset'],w['size'])
print({k:v for k,v in j.items() if k!='windows'})
EOF
echo "== staged"
awk '{print $NF}' "$W/list.txt" | grep -E '^private/var/staged_system_apps/[^/]+\.app$' | sed 's#.*/##' | tr '\n' ' '; echo
echo "== placeholders"
awk '{print $NF}' "$W/list.txt" | grep -E '^System/Library/AppPlaceholders/[^/]+\.app$' | sed 's#.*/##' | tr '\n' ' '; echo
echo "== dyld names"
grep -i -E 'dyld' "$W/list.txt" | awk '{print $NF}' | cut -c1-100 | head -12
echo "== top of the listing"
awk '{print $NF}' "$W/list.txt" | cut -d/ -f1 | sort | uniq -c | sort -rn | head -12
echo "== staged in the seeded Data scan? how the data seed treats it"
grep -rn -a -E 'staged_system_apps' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/scripts /mnt/e/DSH-Fuxi/dump/wsl/*.sh /mnt/e/DSH-Fuxi/dump/wsl/*.py 2>/dev/null | cut -c1-190 | head -12
U=/root/fuxi/src-unixnu
git -C $U log origin/main --format='%h %cI %s' -i --grep='staged\|placeholder\|system app' | cut -c1-120 | head -8
