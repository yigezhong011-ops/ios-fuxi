#!/bin/bash
# Compare the injected bl_kick/dsi code of a build that booted (t32-bl-daily) with one that rebooted (t32-gpu1)
cd /root/fuxi/t32
for k in t32-bl-daily t32-gpu1; do
    llvm-objdump -d --no-show-raw-insn "kernel-$k.blob.elf" | awk '/<bl_kick>:/{on=1} on' | sed -E 's/^ *[0-9a-f]+:[[:space:]]+//' > "/root/fuxi/kick-$k.txt"
    echo "$k: $(wc -l < /root/fuxi/kick-$k.txt) lines"
done
diff /root/fuxi/kick-t32-bl-daily.txt /root/fuxi/kick-t32-gpu1.txt | head -80
