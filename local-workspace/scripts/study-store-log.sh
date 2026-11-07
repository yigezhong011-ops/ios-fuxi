#!/bin/bash
# Read-only: every sign of why the poster store's database did not open, in the last boot's text, and the sandbox and data protection messages.
L=/root/fuxi/wall1/new.txt
for p in 'cannot open file' 'os_unix.c' 'unable to open database' 'SQLITE_' 'sqlite' '.sqlite' 'PRBPosterExtensionDataStore' 'Data store could not' 'dataStore' 'deny(' 'Sandbox' 'data protection' 'NSFileProtection' 'protection class' 'MKB' 'AppleKeyStore' 'keybag' 'Operation not permitted' 'Permission denied' 'PBFDatabase' 'PBFPoster'; do printf '%-30s %s\n' "$p" "$(grep -c -- "$p" $L)"; done
echo "== os_unix"; grep -n -E 'cannot open file|os_unix.c|unable to open database' $L | cut -c1-260 | head -14
echo "== poster paths"; grep -n 'PRBPosterExtensionDataStore' $L | sed -E 's/^([0-9]+):.*(PRBPosterExtensionDataStore.{0,100}).*/\1 \2/' | cut -c1-160 | head -20
echo "== errors"; grep -n -E 'Data store could not|dataStore' $L | cut -c1-260 | head -14
echo "== deny"; grep -n 'deny(' $L | sed -E 's/\([0-9]+\)/(N)/' | cut -c1-200 | grep -i -E 'poster|chrono|widget' | head -14
echo "== sqlite lines"; grep -n -E 'SQLITE_|sqlite' $L | grep -i -E 'poster|error|fail|corrupt|unable' | cut -c1-240 | head -14
echo "== kernel msg deny"; grep -a -i -E 'Sandbox: (PosterBoard|chronod|WidgetRenderer)' /root/fuxi/wall1/log/untagged-2c15ceb80/msgbuf.txt | cut -c1-200 | head -10
