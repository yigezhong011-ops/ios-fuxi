cd /mnt/e/DSH-Fuxi/dump/wsl
grep -l -i 'iPhone15,2\|iPhone14,2\|ProductType\|D73\|d73ap\|MobileGestalt\|com.apple.MobileGestalt' *.sh *.py 2>/dev/null | head -25
echo ---; grep -n -i 'iPhone15,2\|D73\|ProductType\|artwork\|MobileGestalt' make-t50*.sh 2>/dev/null | cut -c1-200 | head -20
echo --- docs; grep -rIl -i 'iPhone15,2\|iPhone14,2\|MobileGestalt' /mnt/e/DSH-Fuxi/*.md 2>/dev/null | head
grep -n -i 'iPhone15,2\|iPhone14,2\|MobileGestalt\|身份' /mnt/e/DSH-Fuxi/*.md 2>/dev/null | cut -c1-230 | head -25
echo --- toml; export MTOOLS_SKIP_CHECK=1; mtype -i /root/fuxi/auto-t50-auto-120fix-p/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a -v '^args' | cut -c1-200 | head -40
mtype -i /root/fuxi/auto-t50-auto-120fix-p/vol.img ::/EFI/UniXNU/unixnu.toml | grep -a '^args' | tr ' ' '\n' | grep -i 'iphone\|product\|model\|identity\|ipad\|hw\.\|device'
echo --- build; grep -rIl -i 'iPhone15,2' /root/fuxi/fuxi2 2>/dev/null --exclude-dir=.git | head -15
grep -rIn -i 'iPhone15,2\|D73AP' /root/fuxi/fuxi2 2>/dev/null --exclude-dir=.git | cut -c1-200 | head -20