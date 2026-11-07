export MTOOLS_SKIP_CHECK=1; cd /root/fuxi
A=auto-t50-auto-120clock-p/vol.img; B=auto-t50-auto-cpu2/vol.img
for f in kernel.macho.adt kernel.macho.trustcache scratch-data.img; do cmp <(mtype -i $A ::/EFI/UniXNU/Payloads/$f) <(mtype -i $B ::/EFI/UniXNU/Payloads/$f) && echo "$f same"; done
cmp <(mtype -i $A ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon) <(mtype -i $B ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon) && echo "addon same"
mcopy -n -i $A ::/EFI/UniXNU/Payloads/kernel.macho /tmp/k1; mcopy -n -i $B ::/EFI/UniXNU/Payloads/kernel.macho /tmp/k2
python3 -I - <<'PY'
a,b=open('/tmp/k1','rb').read(),open('/tmp/k2','rb').read()
d=[i for i in range(len(a)) if a[i]!=b[i]]
print('kernel size same',len(a)==len(b),'diff bytes',len(d),hex(d[0]),hex(d[-1]))
PY
rm -f /tmp/k1 /tmp/k2