#!/bin/bash
# Show the identity nodes of an ADT (root, /product, /buttons, display-scale in /chosen), which MobileGestalt reads.
ADT=${1:-/root/fuxi/t32/p.adt}
for n in /device-tree /device-tree/product /device-tree/buttons; do
  python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py "$n" "$ADT"
done
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/chosen "$ADT" | grep -E '==|display|scale' || true
