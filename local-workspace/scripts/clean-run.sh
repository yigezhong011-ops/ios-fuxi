#!/bin/bash
# Delete exactly the dry run's list plus the unneeded t32 files, as the user agreed (tiers 1 and 2). Every path is checked first. Log: /root/clean-done.txt
set -u
L=/root/clean-delete.txt; K=/root/clean-keep.txt; D=/root/clean-done.txt
[ -s "$L" ] || { echo "no list"; exit 1; }
: > "$D"
while IFS= read -r p; do
  case "$p" in
    /root/uefi-hak-fuxi|/root/uefi-odd|/root/fuxi-touch-kernel|/root/fuxi/?*) ;;
    *) echo "SKIP odd path $p"; continue ;;
  esac
  case "$p" in */..*|*/./*) echo "SKIP $p"; continue ;; esac
  if cut -f2 "$K" | grep -qxF "$p"; then echo "SKIP kept $p"; continue; fi
  [ -d "$p" ] && [ ! -L "$p" ] || { echo "SKIP not a dir $p"; continue; }
  rm -rf -- "$p" && echo "$p" >> "$D"
done < "$L"
# t32: keep the verified kernel and anything a recent script names.
cd /root/fuxi/t32 || exit 1
refs=$(find /mnt/e/DSH-Fuxi/dump/wsl -maxdepth 1 -type f -mtime -3 ! -name 'clean-*' -exec cat {} + 2>/dev/null)
for f in *; do
  case "$f" in kernel-t32-bl-daily.macho|kernel-t32-bl-daily.blob.elf|args.txt) continue ;; esac
  if printf '%s' "$refs" | grep -qF "t32/$f"; then echo "keep t32/$f"; continue; fi
  rm -rf -- "/root/fuxi/t32/$f" && echo "/root/fuxi/t32/$f" >> "$D"
done
echo "removed $(wc -l < "$D") paths"
du -xsh /root/fuxi/t32 /root/fuxi /root 2>/dev/null
df -h / | tail -1
for x in t36 t36-bl2 t50 t50-mine gpu-new-t50-mine src-adrenometal src-unixnu src-adreno740 ios-fuxi; do [ -d /root/fuxi/$x ] && echo "ok $x" || echo "MISSING $x"; done
ls -la /root/fuxi/t32 | cut -c1-90 | head -12
