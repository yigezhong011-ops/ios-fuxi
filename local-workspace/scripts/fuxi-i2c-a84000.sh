#!/bin/bash
# What the stock fuxi DT puts on the I2C engines sheng's backlight driver uses (a84000, 988000), and the panel brightness facts
dtc -I dtb -O dts -q /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Resources/DTBs/fuxi.dtb -o /root/fuxi/fuxi-stock.dts 2>/dev/null
for n in 'i2c@a84000' 'i2c@988000'; do
    echo "== $n"
    awk -v n="$n" '$0 ~ n" \\{" {on=1; depth=0} on {print; depth += gsub(/\{/,"{"); depth -= gsub(/\}/,"}"); if (depth<=0) exit}' /root/fuxi/fuxi-stock.dts \
        | grep -E 'status|compatible|reg =|@[0-9a-f]+ \{|label' | head -30
done
echo "== backlight / brightness"
grep -n -i -E 'ktz8866|backlight|bl-max-level|brightness-max|max-brightness' /root/fuxi/fuxi-stock.dts | head -20
