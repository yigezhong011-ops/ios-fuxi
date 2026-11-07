#!/bin/bash
# Read-only: the store migrator's strings and call sites. Who creates the numbered directory, and what an empty older directory does.
cd /mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc
python3 -I read-store-strings.py $D 'migrat|DataStoreVersion|isDataStoreUpToDate|validateDataStore|integrity|version.*(exist|missing|found)|no such store|createDirectory' 2>&1 | grep -v '^{' | grep -- '<- 0x' | cut -c1-190 | head -50
echo "=== callers of selector stubs"
python3 -I - $D <<'EOF'
import importlib.util, struct, sys
sys.argv = ['x', sys.argv[1]]
spec = importlib.util.spec_from_file_location('c', 'read-dsc-caller-lib.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
tx, n = c.sec['__text']; t = c.rd(tx, n)
want = ('isDataStoreUpToDateForCurrentVersion', 'migrateDataStoreToCurrentVersion:', 'validateDataStoreIntegrity:', 'dataStoreVersion', 'createDirectoryAtURL:withIntermediateDirectories:attributes:error:', 'pbf_dataStoreURLForBaseURL:version:','setupDataStoreIfNeeded','removeDataStoresBeforeCurrentDataStoreVersion')
names = {}
out = {w: [] for w in want}
for off in range(0, n, 4):
    i = struct.unpack_from('<I', t, off)[0]
    if i & 0xfc000000 != 0x94000000: continue
    imm = i & 0x3ffffff
    if imm & (1 << 25): imm -= 1 << 26
    va = tx + off; to = va + imm * 4
    if to not in names: names[to] = c.stub(to)
    if names[to] in out: out[names[to]].append(va)
for k, v in out.items(): print(k, len(v), ' '.join(hex(x) for x in v[:14]))
EOF
