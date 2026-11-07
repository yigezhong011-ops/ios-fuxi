#!/bin/bash
# What does SystemAppMigrator look at, and how did our Data seed set migration? Read-only.
W=/mnt/e/DSH-Fuxi/dump/root-peek/migrator
R=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img
mkdir -p $W /root/fuxi/migrator
cd /root/fuxi/migrator || exit 1
[ -f os.img ] || dd if=$R of=os.img bs=1048576 iflag=skip_bytes,count_bytes skip=1048576 count=6077580800 status=none
7z x -y -bd os.img 'System/Library/DataClassMigrators/SystemAppMigrator.migrator/*' >/dev/null 2>&1
M=System/Library/DataClassMigrators/SystemAppMigrator.migrator
ls -la $M | head
python3 -I -c "import plistlib,sys;print(plistlib.load(open('$M/Info.plist','rb')))" | cut -c1-700
echo "== strings"
strings -a $M/SystemAppMigrator | grep -i -E 'staged|migrat|install|placeholder|upgrade|restore|erase|didUpgrade|should|skip|marker|/var|\.plist|\.app' | cut -c1-140 | sort -u | head -70
echo "== our seed"
grep -rn -E 'LastSystemVersion|com\.apple\.migration|skip-setup|persistent_data|sheng-staged' /mnt/e/DSH-Fuxi/unixnu-build/fuxi --include='*.py' --include='*.toml' --include='*.sh' --include='*.md' 2>/dev/null | cut -c1-170 | head -14
echo "== sheng-lite job names mentioning install or migration"
grep -n -i -E 'install|migrat' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package/*.c /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package/*.h 2>/dev/null | cut -c1-170 | head
rm -f /root/fuxi/migrator/os.img
