#!/bin/bash
# Read-only: what V2 and its USB debug module offer for unattended test loops. Clones under /root/fuxi only.
set -u
R=/root/fuxi/ref-unixnu-fuxi-bare; Q=/root/fuxi/ref-qcomxnuusbdebug
cd "$R" || exit 1
V=V2
echo '== reset commits'
for c in 8a8f13d 4e39610 3291295 c4303a1 2988fa8 a92aed5; do git log -1 --format='--- %h %s%n%b' $c | cut -c1-220 | head -14; done
echo '== submodule pin'; git ls-tree $V drivers/QcomXnuUsbDebug
echo '== scripts/fuxi-usb-debug.sh'; git show $V:scripts/fuxi-usb-debug.sh | cut -c1-170 | head -110
echo '== scripts/run-fuxi-usb-kernel.py'; git show $V:scripts/run-fuxi-usb-kernel.py | cut -c1-170 | head -95
echo '== panic-fastboot patch'; git show $V:scripts/fuxi-usb-panic-fastboot.patch | cut -c1-150 | head -80
if [ -d "$Q/.git" ]; then git -C "$Q" fetch -q origin; else git clone -q https://github.com/ljhhkx529/QcomXnuUsbDebug.git "$Q"; fi
cd "$Q" || exit 1
git log -8 --format='%h %ad %s' --date=short | cut -c1-120
git ls-files | head -50
echo '== control commands in module'
git grep -n -E '"(HELLO|PING|STATUS|SCREENSHOT|REBOOT|RESET|FASTBOOT|BOOTLOADER|RECOVERY|SHUTDOWN)[A-Z_]*"|state=unavailable|bootloader' | cut -c1-170 | head -50
echo '== README'; sed -n 1,70p README.md | cut -c1-190
echo '== what the running image has'
for f in /root/fuxi/t50-scale2/kernel.macho /root/fuxi/t50-wall17/kernel.macho; do [ -f "$f" ] && { echo "$f"; strings -a "$f" | grep -E 'SXNU1R|SCREENSHOT|REBOOT|BOOTLOADER|state=unavailable' | cut -c1-120 | sort -u | head -20; }; done
