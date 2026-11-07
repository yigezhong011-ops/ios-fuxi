#!/bin/bash
# Which image wrote this window? The exporter thread marks 0x6900 only with the cacheexport file. Read-only.
L=$(ls -d /root/fuxi/log-loghang/*/ | head -1)
echo "== 690x in slots, this window"; grep -a -c -E '\b690[01]\b|\b69f[0-4]\b' "$L/slots.txt"
grep -a -n -E '^X7 ' "$L/slots.txt" | cut -c1-90 | awk 'NR%2==1' | head -12
echo "== same rows in a boot known to be without the file"
D=$(ls -d /root/fuxi/log-daily1/*/ | head -1); grep -a -c -E '\b690[01]\b|\b69f[0-4]\b' "$D/slots.txt"
grep -a -n -E '^X7 ' "$D/slots.txt" | cut -c1-90 | head -10
echo "== panic line"
tr -d '\000' < "$L/msgbuf.txt" | grep -a -o -E '.{0,120}(panic\(|Debugger|watchdog).{0,200}' | cut -c1-330 | head -4
echo "== how the plugin opened"
tr -d '\000' < "$L/msgbuf.txt" | grep -a -n -o -E '.{0,50}(gpuaddon|gpu addon|addon mount|ngpu|native_gpu_addon).{0,110}' | cut -c1-200 | head -14
echo "== first and last timestamps"
tr -d '\000' < "$L/msgbuf.txt" | grep -a -o -E '^\[ *[0-9.]+\]' | sed -n '1p;$p'
sed -n 1,6p "$L/latest.txt" | cut -c1-120
