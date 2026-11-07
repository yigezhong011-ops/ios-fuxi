#!/bin/bash
# Read-only: sqlite evidence in the log for the poster store; the connection init and database init code; the on-disk layout of the copy.
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/root/fuxi/sys-peek/dsc; L=/mnt/e/DSH-Fuxi/logs/carve-wallnew/lscan.txt
cd $S
echo "=== log"
for p in 'cannot open file' 'os_unix.c' 'unable to open database' 'SQLITE_CANTOPEN' 'PRBPosterExtensionDataStore/61/' 'PRBPosterExtensionDataStore/59/' 'com.apple.posterboard.sqlite' 'Database migration failed' 'sqliteDatabaseErrorCode' 'Sandbox: PosterBoard' 'deny(1) file' ; do printf '%-40s %s\n' "$p" "$(grep -a -c -- "$p" $L)"; done
grep -a -n -E 'cannot open file|unable to open database' $L | cut -c1-230 | sort -t: -k2 | uniq -c -f1 | sort -rn | head -14
grep -a -E 'PRBPosterExtensionDataStore/[0-9]+/' $L | sed -E 's/.*(PRBPosterExtensionDataStore\/[0-9]+\/.{0,70}).*/\1/; s/[0-9A-F]{8}-[0-9A-F-]{27}/#/g' | sort | uniq -c | sort -rn | head -14
echo "=== SharedInit"
python3 -I read-store-build.py $D 1ca863f40 2a0 | grep -v '^{' | cut -c1-140 | grep -E '; |\bret\b|\bcbz|\bcbnz|tbz|tbnz|\bb\s+0x|\bbl\s' | head -70
echo "=== SQLite database init strings near"
python3 -I read-store-strings.py $D 'PBFPosterExtensionDataStoreSQLiteDatabase|databaseURL|createDirectory|file protection|protection|NSFileProtection|readonly' 2>&1 | grep -v '^{' | cut -c1-180 | head -30
