#!/bin/bash
# Delete what the handoff allows: used carve dumps and superseded test images.
# The do-not-delete list (wechat, steam, keys, token2, flashed images, rollback backups) is untouched.
set -uo pipefail
E=/mnt/e/DSH-Fuxi
before=$(df -B1 --output=avail /mnt/e | tail -1)

rm_tree() {
  local p=$1
  [ -e "$p" ] || return 0
  local s
  s=$(du -sb "$p" 2>/dev/null | cut -f1)
  rm -rf -- "$p" && printf '  删除 %-42s %7.1f MB\n' "${p#$E/}" "$(echo "$s" | awk '{print $1/1048576}')"
}

echo "=== 统一日志 carve（交接文档说用完可删）==="
for d in carve-hello2 carve-hp1 carve-hp2; do rm_tree "$E/logs/$d"; done
echo
echo "=== 我自己的旧 carve ==="
for d in carve-coh2 carve-wallnew carve-mb1 carve-mb2 carve-ab carve-coh carve-tonight carve-autoload; do
  rm_tree "$E/logs/$d"
done
echo
echo "=== 已被取代的测试镜像 ==="
for i in t50-auto-touch t50-auto-touch2 t50-auto-touch3 t50-auto-touch4 t50-auto-touch5 \
         t50-mb1 t50-mb1-wc0 t50-nopause; do
  rm_tree "$E/$i.img"
done
echo
after=$(df -B1 --output=avail /mnt/e | tail -1)
echo "释放 $(echo "$before $after" | awk '{printf "%.2f", ($2-$1)/1073741824}') GB"
df -h /mnt/e | tail -1
