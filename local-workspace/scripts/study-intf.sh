#!/bin/bash
# Read-only: frame counter registers in the upstream display probe, kernel symbols the blob would use, cave size.
cd /root/build/fuxi/package
grep -n -E 'INTF|0xae|0x2b4|0x284|0xac|FRAME|frame_count|kIntf|mdp|Mdp' DisplayTimingProbe.cpp | cut -c1-150 | head -28
K=/root/fuxi/t50/kernel.macho; ls -la $K | cut -c1-80
llvm-nm --defined-only $K | grep -E ' _(IODelay|IOSleep|ml_io_map|kprintf|printf|IOLog|mach_absolute_time|native_backlight_stats)$'
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/find-caves.py $K | grep -A1 __hib_text | head -3
sed -n 1,40p /mnt/e/DSH-Fuxi/dump/wsl/repack-with-vol.py | grep -n -E 'usage|Usage|argv' | head
cmp /root/fuxi/t50-kernel.look /root/fuxi/t50-mine/kernel.macho && echo gpu-fix kernel equals t50-mine kernel
mdir -i /root/fuxi/gpu-new-t50-mine/vol.img ::/EFI/UniXNU/Payloads 2>/dev/null | head -12
echo "== msgbuf tail sample"; tail -3 /root/fuxi/wall1/log/untagged-2c15ceb80/msgbuf.txt | cut -c1-160; wc -c /root/fuxi/wall1/log/untagged-2c15ceb80/msgbuf.txt
ls -la /root/fuxi/t50-mine /root/fuxi/t50 2>&1 | cut -c1-80 | head -14
