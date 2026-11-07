#!/bin/bash
# Read-only: zizhan's working DSI timing switch, for comparison with our sender.
U=https://github.com/qiumochen/UniXNU-zizhan; B=$(git ls-remote $U HEAD | cut -f1); RAW=https://raw.githubusercontent.com/qiumochen/UniXNU-zizhan/$B
cd /root/fuxi/ref-zizhan
curl -fsSL "https://api.github.com/repos/qiumochen/UniXNU-zizhan/git/trees/$B?recursive=1" -o tree.json
python3 -c "
import json
for t in json.load(open('tree.json')).get('tree',[]):
    if 'Scanout' in t['path'] or t['path'].endswith('0011-zizhan-panel-pool-canvases.patch'): print(t['path'])
" | tee list.txt
for p in $(cat list.txt); do curl -fsSL "$RAW/$p" -o "$(basename $p)" ; done
F=$(grep -lE 'dsiDcs|panelHz' * 2>/dev/null | grep -v tree.json | head -1); echo "found in $F"
grep -n -E 'dsiDcs|dsiSet|panelHz|MDP.?busy|mdpBusy' "$F" | cut -c1-120 | head -20
L=$(grep -n -m1 -E 'dsiDcs\(' "$F" | cut -d: -f1); sed -n "$((L-6)),$((L+75))p" "$F" | cut -c1-130
L=$(grep -n -m1 -E 'panelHz\(' "$F" | cut -d: -f1); sed -n "$L,$((L+55))p" "$F" | cut -c1-130
