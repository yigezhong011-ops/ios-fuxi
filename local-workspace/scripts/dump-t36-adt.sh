#!/bin/bash
# t36's ADT: the display/identity nodes that drive the phone layout (identifiers that are device secrets are filtered out).
for n in /device-tree/chosen /device-tree/product /device-tree/buttons; do
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py $n /root/fuxi/t36/t36.adt 2>&1 | grep -viE 'unique-chip|serial-number|random|nonce|seed|ecid|mlb|uid' | head -45
done
