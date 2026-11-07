#!/bin/bash
# Read-only: why the display refused every frame on the iPhone X boot, from the decoded boot log.
D=/mnt/e/DSH-Fuxi/unixnu-build/fuxi/build/sheng-logs/untagged-447e254a
ls -la "$D" | cut -c24- | head -12
F=$(ls -S "$D"/* | head -1)
echo "== $F"
grep -a -n -i -E 'swap|reject|surface|validate|legacy|canvas' "$F" | cut -c1-210 | tail -30
echo "== rows"
grep -a -h -i -E 'swap|reject|validated' "$D"/* 2>/dev/null | cut -c1-210 | sort -u | tail -20
echo "== rejected logger"
grep -n -E 'surface_rejected|swap_validation_observed' -r /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package /mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers/GopFramebuffer 2>/dev/null | cut -c1-210 | head -10
