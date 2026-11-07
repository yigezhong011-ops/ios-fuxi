set -e
export MTOOLS_SKIP_CHECK=1
args(){ mtype -i "$1" ::/EFI/UniXNU/unixnu.toml | grep -a '^args' | sed 's/^args = "//; s/"[ ]*$//' | tr ' ' '\n' | sort; }
cd /root/fuxi
ls -d gpu-new-t50-mine t50-priv auto-t50-auto200p
args gpu-new-t50-mine/vol.img > /tmp/a.txt
args auto-t50-auto200p/vol.img > /tmp/b.txt
wc -l /tmp/a.txt /tmp/b.txt
echo '--- only in daily base'; comm -23 /tmp/a.txt /tmp/b.txt
echo '--- only in auto200p'; comm -13 /tmp/a.txt /tmp/b.txt