#!/bin/bash
# Read-only: can private log data be turned on from a read-only overlay? Looks at the root copy and the shared cache for the preference names.
R=/mnt/e/DSH-Fuxi/dump/root-peek
ls $R | head -20
find $R -maxdepth 5 -type d -path '*Preferences/Logging*' 2>/dev/null | head -8
for f in $(find $R -type f -path '*Preferences/Logging/*' 2>/dev/null | head -5); do echo "$f $(stat -c %s "$f")"; done
find $R -type f -path '*Logging/Subsystems/*' 2>/dev/null | grep -i -E 'poster|chrono|widget' | head -5
echo "== strings"
cd $R/dsc
for s in 'Enable-Private-Data' 'Enable-Logging' 'com.apple.system.logging' '/Library/Preferences/Logging' 'Preferences/Logging/Subsystems'; do
  printf '%-34s ' "$s"; grep -a -l -F -- "$s" dyld_shared_cache_arm64* 2>/dev/null | tr '\n' ' '; echo
done
F=$(grep -a -l -F 'Enable-Private-Data' dyld_shared_cache_arm64* | head -1)
[ -n "$F" ] && grep -a -o -E '[ -~]{0,50}(Enable-Private-Data|Preferences/Logging)[ -~]{0,60}' "$F" | sort -u | head -14 | cut -c1-120
echo "== which binaries"
for b in usr/libexec/logd usr/libexec/diagnosticd; do [ -f $R/$b ] && { echo $b; grep -a -o -E '[ -~]{0,40}(Enable-Private|Preferences/Logging|private-data)[ -~]{0,40}' $R/$b | sort -u | head -8; }; done
echo "== how the wall image overlaid"
sed -n 45,70p /mnt/e/DSH-Fuxi/dump/wsl/make-t50-gpu-wall.sh | cut -c1-170
