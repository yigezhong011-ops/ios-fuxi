#!/bin/bash
# Read-only: what fills logs, ux-out, backup and WSL.
cd /mnt/e/DSH-Fuxi
echo '--- logs, largest'; du -xsh logs/* 2>/dev/null | sort -rh | head -22
echo "logs: $(find logs -maxdepth 1 -type f | wc -l) top-level files"
echo '--- ux-out'; du -xh --max-depth=3 ux-out 2>/dev/null | sort -rh | head -8
find ux-out -type f -size +200M -printf '%10s %TY-%Tm-%Td %p\n' | sort -rn | head
echo '--- backup'; du -xsh backup/* 2>/dev/null | sort -rh | head -8
echo '--- /root/fuxi, largest'; du -xsh /root/fuxi/* 2>/dev/null | sort -rh | head -30
echo '--- /root other'; du -xsh /root/* /root/.[a-z]* 2>/dev/null | sort -rh | head -12
echo '--- wsl fs'; df -h / | tail -1; ls -la /mnt/e/WSL/* 2>/dev/null | cut -c24- | head -8
ps -eo pid,comm,etime --no-headers | grep -v -E ' (ps|grep|bash|init|sh|sort|Relay|SessionLeader|login)' | head
