#!/bin/bash
# Read-only: the poster store tree, its container's metadata and the migration plist on the Data copy.
A="python3 -I /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py /mnt/e/DSH-Fuxi/logs/data-raw.img"
C=mobile/Containers/Data/Application/353FB615-9AD2-407D-B79C-EFF255D5432B
mkdir -p /root/fuxi/data-look
$A tree 0 "$C/Library/Application Support/PRBPosterExtensionDataStore" 4 2>&1 | cut -c1-150 | head -70
echo "== prefs"; $A ls 0 "$C/Library/Preferences" 2>&1 | cut -c1-130
$A get 0 "$C/.com.apple.mobile_container_manager.metadata.plist" /root/fuxi/data-look/meta.plist
$A get 0 mobile/Library/Preferences/com.apple.migration.plist /root/fuxi/data-look/migration.plist
python3 -I - <<'EOF'
import plistlib
print(plistlib.load(open('/root/fuxi/data-look/meta.plist', 'rb')))
print(plistlib.load(open('/root/fuxi/data-look/migration.plist', 'rb')))
EOF
