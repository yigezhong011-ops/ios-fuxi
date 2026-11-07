#!/bin/bash
# Read-only: containers on the Data copy, migration results, and every log line naming the poster store or system containers.
A="python3 -I /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py /mnt/e/DSH-Fuxi/logs/data-raw.img"
L=/mnt/e/DSH-Fuxi/logs/carve-wall1/lscan.txt
M=/root/fuxi/wall1/log/untagged-2c15ceb80/msgbuf.txt
mkdir -p /root/fuxi/data-look; cd /root/fuxi/data-look
echo "== containers"; $A ls 0 containers 2>&1 | cut -c1-90; $A ls 0 containers/Data 2>&1 | cut -c1-90; $A ls 0 containers/Data/System 2>&1 | wc -l; $A ls 0 containers/Shared/SystemGroup 2>&1 | wc -l
$A ls 0 mobile/Containers/Shared/AppGroup 2>&1 | wc -l
echo "== system containers named Poster/Paper"
for base in containers/Data/System containers/Shared/SystemGroup mobile/Containers/Shared/AppGroup; do
  $A ls 0 $base 2>/dev/null | awk '{print $NF}' | while read u; do
    if $A get 0 "$base/$u/.com.apple.mobile_container_manager.metadata.plist" m.plist >/dev/null 2>&1; then
      id=$(python3 -I -c "import plistlib;print(plistlib.load(open('m.plist','rb')).get('MCMMetadataIdentifier'))")
      case "$id" in *[Pp]oster*|*[Pp]aper*|*allpaper*|*chrono*|*Chrono*) echo "$base/$u $id";; esac
    fi
  done
done
echo "== migration wrapper"; $A get 0 mobile/Library/Preferences/com.apple.migrationpluginwrapper.plist w.plist; python3 -I -c "
import plistlib;d=plistlib.load(open('w.plist','rb'));print(str(d)[:1500])"
echo "== datamigrator"; $A tree 0 datamigrator 3 2>&1 | cut -c1-120 | head -14
echo "== msgbuf"; grep -a -n -E 'system container|PosterBoard|PRBPoster' $M | cut -c1-200 | awk '!s[substr($0,index($0,"]"))]++' | head -24
echo "== lscan system container"; grep -a -F -e 'system container path' $L | cut -c1-200 | sort | uniq -c | sort -rn | head -12
grep -a -c -F 'PRBPosterExtensionDataStore' $L
grep -a -F 'PRBPosterExtensionDataStore' $L | cut -c1-260 | sed -E 's/[0-9A-F]{8}-[0-9A-F-]{27}/UUID/g' | sort | uniq -c | sort -rn | head -24
