#!/usr/bin/env python3
# My new study scripts took the names of older ones. Keep mine under new names and put back the older text found in the session records.
import glob, json, os, shutil
D = '/mnt/e/DSH-Fuxi/dump/wsl/'
for name, new in (('study-coh.sh', 'study-hang-coh.sh'), ('study-coh2.sh', 'study-hang-coh2.sh')):
    mine = open(D + name, 'rb').read()
    found = []
    for f in sorted(glob.glob('/mnt/c/Users/USER/.claude/projects/E--DSH-Fuxi/*.jsonl'), key=os.path.getmtime):
        for line in open(f, encoding='utf8', errors='ignore'):
            if name not in line or '"Write"' not in line:
                continue
            try:
                m = json.loads(line)
            except ValueError:
                continue
            c = m.get('message', {}).get('content')
            if not isinstance(c, list):
                continue
            for b in c:
                if isinstance(b, dict) and b.get('type') == 'tool_use' and b.get('name') == 'Write' and b['input'].get('file_path', '').replace('\\', '/').endswith('/' + name):
                    found.append(b['input']['content'].encode())
    older = [t for t in found if t.replace(b'\r\n', b'\n') != mine.replace(b'\r\n', b'\n')]
    print(name, 'versions in records', len(found), 'older', len(older))
    shutil.copy(D + name, D + new)
    if older:
        open(D + name, 'wb').write(older[-1])
        print('  restored', len(older[-1]), 'bytes; first line:', older[-1].split(b'\n')[1][:100])
