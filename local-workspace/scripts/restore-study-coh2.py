#!/usr/bin/env python3
# The two old study scripts were written by here-strings in session 2be865ec; put that text back under their names.
import json
D = '/mnt/e/DSH-Fuxi/dump/wsl/'
F = '/mnt/c/Users/USER/.claude/projects/E--DSH-Fuxi/2be865ec-336f-4365-82ee-b23006324ef5.jsonl'
for n, line in enumerate(open(F, encoding='utf8', errors='ignore'), 1):
    if n not in (5499, 5509):
        continue
    for b in json.loads(line)['message']['content']:
        if not (isinstance(b, dict) and b.get('type') == 'tool_use'):
            continue
        c = b['input'].get('command', '')
        for name in ('study-coh.sh', 'study-coh2.sh'):
            if 'dump\\wsl\\' + name in c:
                text = c[c.index("@'") + 2:c.index("\n'@")].lstrip('\n') + '\n'
                open(D + name, 'w', newline='\n').write(text)
                print(name, len(text), 'bytes:', text.split('\n')[1][:90])
