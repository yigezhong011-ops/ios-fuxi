#!/bin/bash
# Read-only study: the USB debug driver (public repo, new directory, nothing built or run from it), t50's copy, our serial logs.
E=/mnt/e/DSH-Fuxi; W=/root/fuxi/ref-qud; K=/root/fuxi/t50/kernel.macho
[ -d "$W/.git" ] || timeout 120 git clone -q https://github.com/xiaoleGun/QcomXnuUsbDebug.git "$W" 2>&1 | tail -1
cd "$W" || exit 1
git log -5 --date=short --format='%h %ad %s' | cut -c1-100
echo "pinned by V2: 83be5782 -> $(git rev-list --count 83be5782..HEAD 2>/dev/null) commits behind HEAD"
ls | tr '\n' ' '; echo; ls docs host tools scripts 2>/dev/null | tr '\n' ' '; echo
echo "=== README"; cut -c1-200 README.md | head -90
echo "=== boundaries"; [ -f docs/boundaries.md ] && cut -c1-190 docs/boundaries.md | head -50
echo "=== boot args"; grep -rnoE '"qcom-usb[a-z0-9-]*"' kernel include 2>/dev/null | sort -u | cut -c1-90 | head -14
echo "=== control commands"; grep -rnE 'STATUS|SCREENSHOT|REBOOT|nohook' kernel include docs 2>/dev/null | cut -c1-150 | head -24
echo "=== t50 strings"
strings -a $K | grep -E 'qcom-usb|QUD|FuxiXnuUsbDebug|nohook|SCREENSHOT|STATUS ok' | cut -c1-120 | sort -u | head -24
llvm-nm $K | grep -iE 'qcom_usb|fuxi_usb|usb_ctl|qud_' | cut -c18-70 | head -24
echo "=== args in images"
tr ' ' '\n' < /root/fuxi/t50/args.txt | grep -iE 'usb|serial|debug' | tr '\n' ' '; echo
echo "=== newest good serial log"
L=$(ls -t $E/logs/com3-t50-auto-120clock-p-*.log | head -1); echo "$L $(wc -c < "$L")"
tr -d '\r' < "$L" | head -6 | cut -c1-130
echo "..."; tr -d '\r' < "$L" | grep -aoE '^\[ *[0-9.]+\]' | sed -n '1p;$p'
tr -d '\r' < "$L" | grep -anE 'dropped|overrun|lost' | head -4 | cut -c1-120
tr -d '\r' < "$L" | tail -3 | cut -c1-130
ls $E/dump/wsl | grep -iE 'usb|com3|serial' | tr '\n' ' '; echo
