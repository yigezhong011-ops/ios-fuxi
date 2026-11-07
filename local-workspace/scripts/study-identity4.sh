export MTOOLS_SKIP_CHECK=1
IMG=/mnt/e/DSH-Fuxi/logs/data-raw.img; A=/mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py
python3 -I $A $IMG info 2>&1 | cut -c1-160 | head -14
for v in 0 1 2 3; do
  r=$(python3 -I $A $IMG ls $v /containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches 2>&1 | tail -4 | cut -c1-160)
  echo "vol $v: $r"
done
mkdir -p /root/fuxi/idscan; cd /root/fuxi/idscan
mtype -i /root/fuxi/auto-t50-auto-120fix-p/vol.img ::/EFI/UniXNU/Payloads/kernel.macho.adt > adt.bin; ls -la adt.bin
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree adt.bin | cut -c1-120 | head -16
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/product adt.bin | cut -c1-120
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/buttons adt.bin | cut -c1-120
python3 -I /mnt/e/DSH-Fuxi/dump/wsl/adt-node-props.py /device-tree/chosen adt.bin | grep -E 'display|scale' | cut -c1-120