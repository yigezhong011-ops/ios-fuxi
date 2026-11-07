#!/bin/bash
# Read-only: all sandbox denials of the last boot in summary, then the context of the GPU denials and of PosterBoard.
L=/root/fuxi/wall1/new.txt
echo "== summary"; grep -a 'Sandbox: .* deny(' $L | sed -E 's/^.*Sandbox: //; s/\([0-9]+\)//' | cut -c1-110 | sort | uniq -c | sort -rn | head -40
echo "== iokit denials by client"; grep -a -E 'deny\(1\) iokit' $L | sed -E 's/^.*Sandbox: //; s/\([0-9]+\)//' | cut -c1-110 | sort | uniq -c | sort -rn | head -24
echo "== poster denials"; grep -a -i 'Sandbox: .*poster' $L | cut -c1-200 | sed -E 's/\([0-9]+\)//' | sort | uniq -c | sort -rn | head -14
echo "== widget renderer around 96891"; sed -n 96880,96900p $L | cut -c1-200
echo "== after it, m2v or metal mentions"; grep -a -n -E 'WidgetRenderer_Default|MTLCreateSystemDefaultDevice|no Metal|Metal device|GPU.*(not|un)available|software render|CGSoftware' $L | cut -c1-200 | sed -n 1,20p
echo "== kernel side: gpu rows"
M=/root/fuxi/wall1/log/untagged-2c15ceb80
grep -a -E 'slot|refused|e00002d5' $M/latest.txt | cut -c1-170 | head -24
