#!/bin/bash
set -uo pipefail
cd /root/ios-fuxi
echo "=== mkadt-fuxi 用法 ==="
python3 tools/mkadt-fuxi.py --help 2>&1 | head -12
echo
echo "=== 生成 ADT ==="
python3 tools/mkadt-fuxi.py -o /root/fuxi/fuxi-new.adt 2>&1 | tail -6
ls -l /root/fuxi/fuxi-new.adt 2>/dev/null
echo
echo "=== 新 ADT 里是否有 product 节点 ==="
strings /root/fuxi/fuxi-new.adt 2>/dev/null | grep -i -m5 'product-type\|device-class\|iPad\|iPhone' 
