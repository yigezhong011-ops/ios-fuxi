#!/bin/bash
# The store's init from its first signpost through both failure logs. Read-only.
S=/mnt/e/DSH-Fuxi/dump/wsl; D=/mnt/e/DSH-Fuxi/dump/root-peek/dsc
cd $S
python3 -I read-dsc-xref.py $D d 0x1ca834c48 1c0 640 2>&1 | grep -E ' ; |^==|cbz|cbnz|tbz|tbnz|ret|pacibsp' | cut -c1-165
echo "== who else: the block before build"
python3 -I read-dsc-xref.py $D d 0x1ca915550 110 60 2>&1 | grep -E ' ; |^==|cbz|cbnz|ret' | cut -c1-150
