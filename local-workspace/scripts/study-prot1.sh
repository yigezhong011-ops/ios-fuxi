#!/bin/bash
# Read-only: how the kernel answers a protection class read, and where userland checks it.
cd /mnt/e/DSH-Fuxi/dump/wsl
K=/root/fuxi/t50/kernel.macho
D=/root/fuxi/sys-peek/dsc
A="python3 -I /mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py /mnt/e/DSH-Fuxi/logs/data-raw.img"
echo "=== 59"; $A ls 0 "mobile/Containers/Data/Application/353FB615-9AD2-407D-B79C-EFF255D5432B/Library/Application Support/PRBPosterExtensionDataStore/59" 2>&1 | cut -c1-100 | head
echo "=== kernel symbols"
llvm-nm $K | grep -E ' _(sys_fcntl_nocancel|fcntl_nocancel|getattrlist_internal|getattrlist|fgetattrlist|getattrlistat|attr_pack_common|vnode_attr_authorize_dir_clone|cp_key_store_action|cp_vnode_getclass|vfs_context_can_resolve_triggers)$' | cut -c1-80
strings -a $K | grep -E '^(F_GETPROTECTIONCLASS|cp_is_supported_version)$' | head
tr -d '\r' < read-store-strings.py > /tmp/rss.py
sed -n 1,12p /tmp/rss.py | cut -c1-140
echo "=== strings"
python3 -I /tmp/rss.py $D 'FileProtectionKey|PFPosterPathURLResourceValues|ConformToResourceValues|pbf_URLIsReachable' 2>/dev/null | cut -c1-150 | head -24
