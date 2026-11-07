#!/bin/bash
D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
S=/mnt/e/DSH-Fuxi/dump/wsl
# Library copy of read-dsc-caller.py without its printing main part.
python3 -I - <<'EOF'
src = open('/mnt/e/DSH-Fuxi/dump/wsl/read-dsc-caller.py').read()
i = src.index("sec = macho_sections()")
j = src.index("for name in ('__cstring', '__oslogstring'):")
k = src.index("def dump(start")
l = src.index("for addr in sys.argv[2:]:")
open('/mnt/e/DSH-Fuxi/dump/wsl/read-dsc-caller-lib.py', 'w').write(src[:j] + src[k:l])
EOF
python3 -I $S/read-dsc-xref.py $D d +4b1a4 90 20 2>&1 | cut -c1-130
python3 -I $S/read-dsc-xref.py $D x 'Opting to place data store' 'Unable to setup dataStore URL' 'Unable to reach dataStore URL' 'Data store could not be created' 'Datastore could not be loaded' 'failed to setup database' 'could not setup data store' 'bootstrapDataStoreAssertion' 'No data store @' 2>&1 | cut -c1-200
echo "== export switch"
cd /root/fuxi/src-adrenometal
grep -rn -E 'cacheexport' --include='*' . 2>/dev/null | grep -v '^./CacheExport.h' | cut -c1-170 | head -8
grep -n -E 'runOsLog|OsLogExport|kDirectory|oslogexport' -r . 2>/dev/null | cut -c1-150 | head -8
strings -a /root/fuxi/t50-mine/kernel.macho | grep -E 'NativeAdrenoMetal\.cacheexport|cacheexport|SHEXR001|sheng_export|export_blob' | head
