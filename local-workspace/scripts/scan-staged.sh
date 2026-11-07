#!/sbin/sh
# Runs in TWRP. Read-only: traces of the staged copy in the Data area. Rows: <chunk MiB>:<offset>:<string>
D=/dev/block/by-name/userdata
i=0
while [ $i -lt 16384 ]; do
  dd if=$D bs=1048576 skip=$((212039 + i)) count=65 2>/dev/null | grep -a -b -o -F -e .sheng-staged-apps -e staged_system_apps -e SequoiaTranslator.app -e Freeform.app | sed "s/^/$i:/"
  i=$((i + 64))
done
echo done
