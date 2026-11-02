#!/bin/bash
# Brightness facts of the fuxi M3 panel (stock DT) and the DSI0 controller node; houji's record status (read-only)
D=/root/fuxi/fuxi-stock.dts
[ -f $D ] || dtc -I dtb -O dts -q /mnt/e/DSH-Fuxi/unixnu-build/uefi-fuxi/Resources/DTBs/fuxi.dtb -o $D
ln=$(grep -n 'xiaomi m3 38 0c 0a sec cmd mode dsc dsi panel' $D | head -1 | cut -d: -f1)
echo "panel node at line $ln"
sed -n "$((ln-5)),$((ln+400))p" $D | grep -n -E 'bl-|brightness|backlight|dimming|51 0|hbm|dcs' | head -40
echo "== dsi controller nodes"
grep -n -E 'qcom,dsi-ctrl@|dsi_ctrl0|ae94000|ae96000' $D | head
echo "== houji record"
python3 /mnt/e/DSH-Fuxi/dump/wsl/device-input-area.py houji 2>/dev/null | head -3
python3 /root/fuxi/da.py houji display 2>/dev/null | grep -i -E 'status|backlight|brightness|DSI' | head -20
