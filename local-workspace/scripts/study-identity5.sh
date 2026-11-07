R=/mnt/e/DSH-Fuxi/ux-out/fuxi/userdata/userdata-root.img; ls -la $R
mkdir -p /root/fuxi/idscan; cd /root/fuxi/idscan
[ -s root-list.txt ] || 7z l -ba $R > root-list.txt 2>/dev/null
wc -l root-list.txt; head -3 root-list.txt | cut -c1-140
path(){ awk '{print $NF}' root-list.txt; }
echo "== all files with ~iphone / ~ipad suffix"
printf 'iphone %s  ipad %s\n' "$(grep -c '~iphone' root-list.txt)" "$(grep -c '~ipad' root-list.txt)"
echo "== keyboard: names"
grep -i 'keyboard\|TextInput' root-list.txt | grep -i 'iphone\|ipad\|layout\|artwork' | awk '{print $NF}' | cut -c1-120 | head -30
echo "== Bundle dirs"
grep -E 'System/Library/TextInput/[^/]+$' root-list.txt | awk '{print $NF}' | head -12
echo "== top dirs with ~ipad"; grep '~ipad' root-list.txt | awk '{print $NF}' | sed -E 's#^(([^/]*/){0,5}).*#\1#' | sort | uniq -c | sort -rn | head -14
echo "== top dirs with ~iphone"; grep '~iphone' root-list.txt | awk '{print $NF}' | sed -E 's#^(([^/]*/){0,5}).*#\1#' | sort | uniq -c | sort -rn | head -14
A=/mnt/e/DSH-Fuxi/dump/wsl/apfs-read.py; B=/mnt/e/DSH-Fuxi/logs/gestalt-backup-14pro.plist
python3 -I $A /mnt/e/DSH-Fuxi/logs/data-raw.img get 0 /containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist $B 2>&1 | tail -1 | cut -c1-150
python3 -I - $B <<'PY'
import plistlib,sys
d=plistlib.load(open(sys.argv[1],'rb'))
print('top keys',list(d)[:8])
c=d.get('CacheExtra',d)
print('CacheVersion',d.get('CacheVersion'),'entries',len(c))
for k in ('oPeik/9e8lQWMszEjbPzng','ArtworkTraits','h9jDsbgj7xIVeIQ8S3/X3Q','0+nc/Udy4WNG8S+Q7a/s1A','ProductType','Z/dqyWS6OZTRy10UcmUAhw','qNNddlUK+B/YlooNoymwgA'):
    if k in c: print(k, repr(c[k])[:220])
PY