#!/bin/bash
# The identity nodes of t32's ADT (root, /product, /buttons) and the Data persistence arguments
A=/root/fuxi/t32/p.adt
for n in /device-tree /device-tree/product /device-tree/buttons; do
    echo "== $n"
    python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py "$n" "$A" 2>&1 | grep -v -E '^\s*$' | head -40
done
echo "== args"
tr ' ' '\n' < /root/fuxi/t32/args.txt | grep -E 'data|persist|seed|setup|aks'
