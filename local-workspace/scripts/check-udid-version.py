#!/usr/bin/env python3
# Read only: looks through the payload files for udid-version and prints only that property, never any identifier. Usage: <vol.img>
import re, struct, subprocess, sys, os
vol = sys.argv[1]
env = dict(os.environ, MTOOLS_SKIP_CHECK='1')
ls = subprocess.run(['mdir', '-/', '-b', '-i', vol, '::/EFI/UniXNU'], capture_output=True, text=True, env=env).stdout
files = [x.strip() for x in ls.splitlines() if x.strip() and not x.strip().endswith('/')]
print('files', len(files))
for f in files:
    d = subprocess.run(['mtype', '-i', vol, f], capture_output=True, env=env).stdout
    i = d.find(b'udid-version')
    print('%-48s %10d %s' % (f.split('::')[-1][-48:], len(d), 'udid-version at %#x' % i if i >= 0 else ''))
    if i < 0:
        continue
    for m in re.finditer(rb'udid-version', d):
        i = m.start()
        print('   name bytes', d[i:i + 32].rstrip(b'\0'), 'then', d[i + 32:i + 44].hex())
    # Neighbouring property names of the same node, names only.
    near = d[max(0, i - 4000):i + 4000]
    names = sorted(set(x.decode() for x in re.findall(rb'[a-z][a-z0-9-]{3,31}(?=\0{4})', near)))
    print('   nearby', [n for n in names][:40])
