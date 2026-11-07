#!/bin/bash
set -euo pipefail
exec > >(tee /root/fuxi/finish-root.log) 2>&1
cd /root/fuxi
echo "=== 清理残留挂载 ==="
for m in $(mount | awk '/hfsplus/{print $3}' | sort -r); do umount -l "$m" 2>/dev/null || true; done
mount | grep -i hfsplus || echo "(clean)"

echo "=== 挂载镜像 ==="
mkdir -p /root/fuxi/mnt/root
mount -t hfsplus -o loop,force /root/fuxi/iosroot.img /root/fuxi/mnt/root
R=/root/fuxi/mnt/root
df -h "$R" | tail -1

echo "=== 内容核查 ==="
ls "$R" | head
[ -f "$R/System/Library/CoreServices/SystemVersion.plist" ] && echo "SystemVersion OK"
ls "$R/private/preboot/Cryptexes" 2>/dev/null

echo "=== 补 logd 目录（uid/gid 272）==="
DB="$R/private/var/db"
mkdir -p "$DB/diagnostics" "$DB/uuidtext" "$DB/diagnostics/timesync"
chown 272:272 "$DB/diagnostics" "$DB/uuidtext" "$DB/diagnostics/timesync"
chmod 0751 "$DB/diagnostics"
chmod 0755 "$DB/uuidtext" "$DB/diagnostics/timesync"
for d in diagnostics uuidtext diagnostics/timesync; do
  : > "$DB/$d/.migrated"
  chown 272:272 "$DB/$d/.migrated"
  chmod 0644 "$DB/$d/.migrated"
done
ls -ln "$DB" | head -5
ls -ln "$DB/diagnostics" | head -3

echo "=== system keybag ==="
mkdir -p "$R/private/var/keybags"
chmod 0700 "$R/private/var/keybags"
chown 0:0 "$R/private/var/keybags"
cat > "$R/private/var/keybags/systembag.kb" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>KeyBagKeys</key><data>U1dFRVQ=</data></dict></plist>
PLIST
chmod 0600 "$R/private/var/keybags/systembag.kb"
chown 0:0 "$R/private/var/keybags/systembag.kb"
ls -ln "$R/private/var/keybags"

echo "=== 卸载并 fsck ==="
sync
du -sh "$R" || true
umount "$R"
fsck.hfsplus -f -y /root/fuxi/iosroot.img 2>&1 | grep -v 'Illegal name' | tail -5 || true
fsck.hfsplus -f -n /root/fuxi/iosroot.img | tail -3
ls -lh /root/fuxi/iosroot.img
du -h --apparent-size /root/fuxi/iosroot.img
echo "FINISH_ROOT_OK"
