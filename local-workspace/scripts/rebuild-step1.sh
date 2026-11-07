#!/bin/bash
# Rebuild the payload from scratch with the wallpaper in the addon. The in-place addon
# rule does not apply to a fresh payload: its Data seed is generated here.
set -uo pipefail
LOG=/root/rebuild-payload.log
: > "$LOG"
exec >>"$LOG" 2>&1
echo "=== $(date) 开始 ==="

W=/root/rebuild
rm -rf "$W"; mkdir -p "$W"
mount -t vfat -o loop,ro /root/fuxi/t32/vol.img "$W/mnt" 2>/dev/null || { mkdir -p "$W/mnt"; mount -t vfat -o loop,ro /root/fuxi/t32/vol.img "$W/mnt"; }
cp "$W/mnt/EFI/UniXNU/Payloads/kernel.macho.trustcache" "$W/trustcache" 2>/dev/null
cp "$W/mnt/EFI/UniXNU/Payloads/scratch-data.img" "$W/data.img" 2>/dev/null
cp "$W/mnt/EFI/UniXNU/unixnu.toml" "$W/unixnu.toml" 2>/dev/null
umount "$W/mnt" 2>/dev/null
ls -l "$W"

echo "--- t32 的启动参数 ---"
grep -o 'args = "[^"]*"' "$W/unixnu.toml" | sed 's/^args = "//; s/"$//' > "$W/args.txt"
wc -w < "$W/args.txt"

echo "--- 新附加包（含壁纸） ---"
TREE=/mnt/e/DSH-Fuxi/unixnu-build/unixnu
ADRENO_PLUGIN_DIR=/root/fuxi/addon-new/plugin \
python3 "$TREE/scripts/make-gpu-addon.py" --publish \
  --clients 'SpringBoard,WidgetRenderer_Default,iconservicesagent,Preferences' \
  --wallpaper /root/wallpaper-overlay \
  "$W/addon.ngpu" 2>&1 | tail -15
ls -l "$W/addon.ngpu" 2>/dev/null

echo "=== $(date) 第一阶段结束 ==="
