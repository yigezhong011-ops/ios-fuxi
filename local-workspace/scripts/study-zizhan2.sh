#!/bin/bash
# Read-only: zizhan's 120 Hz notes, and where fuxi-backlight=dsi lives in sources and in the t50 kernel.
R=/mnt/e/DSH-Fuxi/dump/wsl/zizhan-repo.txt
U=$(sed -n 24p /root/fuxi/up-latest/docs/.vitepress/device-records/zizhan.toml | grep -oE 'https://github.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | head -1); echo "repo $U"
B=$(git ls-remote "$U" HEAD | cut -f1); echo "head $B"
RAW=${U/github.com/raw.githubusercontent.com}
mkdir -p /root/fuxi/ref-zizhan
for f in docs/progress/2026-11-01-120hz-and-cadence.md; do curl -fsSL "$RAW/$B/$f" -o /root/fuxi/ref-zizhan/$(basename $f) && cut -c1-500 /root/fuxi/ref-zizhan/$(basename $f) | head -70; done
curl -fsSL "https://api.github.com/repos/${U#https://github.com/}/git/trees/$B?recursive=1" | python3 -c "
import json,sys
for t in json.load(sys.stdin).get('tree',[]):
    p=t['path']
    if any(k in p.lower() for k in ('120','panel','0011','0012','0013','0009')) and t['type']=='blob': print(p)
" | head -30
echo "== backlight=dsi sources"
grep -rIl -E 'fuxi-backlight' /root/fuxi /root/build --include='*.c' --include='*.cpp' --include='*.h' --include='*.patch' --include='*.toml' --include='*.py' 2>/dev/null | head -20
echo "== t50 kernel"; strings -a -t x /root/fuxi/t50-kernel.look | grep -E 'fuxi-backlight|sheng-vsync|sheng-fb-gpu' | head
