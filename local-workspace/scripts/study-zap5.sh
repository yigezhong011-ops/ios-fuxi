#!/bin/bash
# Read-only: what the notes say about hang boots, and what resets a stuck boot at about 125 s.
V=/root/fuxi/ref-fuxi-v2
cd /mnt/e/DSH-Fuxi
echo "=== notes"
grep -n -E '卡米|Mi.?logo|back=12|125 ?s|125 秒|t=12' *.md 2>/dev/null | cut -c1-170 | head -40
echo "=== autoreset in V2"
git -C $V grep -n -I -E 'autoreset|sheng-autoreset' HEAD -- 'package/*' 2>/dev/null | cut -c1-170 | head -20
echo "=== autoreset in t50 strings"
strings -a /root/fuxi/t50/kernel.macho | grep -E 'autoreset|watchdog|wdog' | cut -c1-110 | head -20
echo "=== how run scripts read a hang"
grep -l -E 'slots|carve' dump/wsl/*.ps1 dump/wsl/*.sh 2>/dev/null | head -20
echo "=== logs dirs by date"
ls -dt logs/carve-* 2>/dev/null | head -14
