K=/root/fuxi/t50-mine/kernel.macho
grep -rIl --exclude-dir=.git --exclude-dir=out 'native_gpu_addon_mount' /root/build/unixnu /root/fuxi/unixnu-pin /root/fuxi/fuxi2 2>/dev/null | head -6
F=$(grep -rIl --exclude-dir=.git --exclude-dir=out 'native_gpu_addon_mount' /root/fuxi/unixnu-pin /root/build/unixnu 2>/dev/null | grep -E '\.(c|cpp|patch|py)$' | head -1); echo "FILE $F"
grep -n 'native_gpu_addon_mount\|wallpaper\|panic\|MNT_UNION' "$F" | cut -c1-190 | head -30
L=$(grep -n 'native_gpu_addon_mount' "$F" | head -1 | cut -d: -f1); sed -n "$L,$((L+55))p" "$F" | cut -c1-170
echo "=== daily vs test addon list"; export MTOOLS_SKIP_CHECK=1
python3 -I - <<'PY'
import struct,subprocess
for n,v in (('daily-base','/root/fuxi/gpu-new-t50-mine/vol.img'),('auto-cpu','/root/fuxi/auto-t50-auto-cpu/vol.img'),('120fix','/root/fuxi/auto-t50-auto-120fix-p/vol.img')):
    b=subprocess.run(['mtype','-i',v,'::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon'],capture_output=True).stdout
    c=struct.unpack_from('<I',b,8)[0];at=24;names=[]
    for _ in range(c):
        nl,m,s,p=struct.unpack_from('<IIQQ',b,at);at+=24;names.append(b[at:at+nl-1].decode());at+=(nl+7)//8*8+(p+7)//8*8
    print(n,len(b),c,[x for x in names if 'wallpaper' in x or 'filler' in x][:6])
PY
sha256sum /mnt/e/DSH-Fuxi/t50-mine-gpu-fix.img /mnt/e/DSH-Fuxi/t50-auto-cpu.img | cut -c1-16
cmp <(mtype -i /root/fuxi/gpu-new-t50-mine/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon) <(mtype -i /root/fuxi/auto-t50-auto-cpu/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.gpuaddon) && echo addon same