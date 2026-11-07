#!/bin/bash
set -uo pipefail
L=/root/fuxi/mon39/boot.log
echo "=== fuxi_touch 的日志 ==="
tr -d '\000' < "$L" | grep -a -i 'fuxitouch\|FUXI TOUCH\|touch:' | tail -15
echo
echo "=== SWEET HID 相关 ==="
tr -d '\000' < "$L" | grep -a 'SWEET HID' | tail -8
echo
echo "=== 触摸控制器探测（SPI/I2C/GPIO）==="
tr -d '\000' < "$L" | grep -a -i 'spi\|i2c\|geni\|gt9916\|focaltech\|goodix' | tail -10
