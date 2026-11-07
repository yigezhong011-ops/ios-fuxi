#!/bin/bash
set -uo pipefail
A=/root/fuxi/t50-mine/kernel.macho
B=/root/fuxi/t36-bl2/kernel.macho
strings -a "$A" | grep 'NativeAdreno' | sort -u > /root/fuxi/sym-t50.txt
strings -a "$B" | grep 'NativeAdreno' | sort -u > /root/fuxi/sym-t36.txt
echo "t50 独有（t50 有、t36 没有）:"
comm -23 /root/fuxi/sym-t50.txt /root/fuxi/sym-t36.txt | head -25 | cut -c1-140
echo "共 $(comm -23 /root/fuxi/sym-t50.txt /root/fuxi/sym-t36.txt | wc -l) 条"
echo
echo "t36 独有:"
comm -13 /root/fuxi/sym-t50.txt /root/fuxi/sym-t36.txt | head -15 | cut -c1-140
echo "共 $(comm -13 /root/fuxi/sym-t50.txt /root/fuxi/sym-t36.txt | wc -l) 条"
echo
echo "两版共有: $(comm -12 /root/fuxi/sym-t50.txt /root/fuxi/sym-t36.txt | wc -l) 条"
