#!/bin/bash
# Read-only: the stage before the kernel's USB start, where a boot without any COM3 must have stopped.
E=/mnt/e/DSH-Fuxi
echo "=== usb_init ticks in good boots (seconds since the counter started)"
for f in $(ls -t $E/logs/com3-*.log 2>/dev/null | head -30); do
  a=$(grep -a -m1 -o -E 'stage=usb_init_begin counter_ticks=[0-9]+' "$f" | sed 's/.*=//')
  b=$(grep -a -m1 -o -E 'stage=usb_init_end counter_ticks=[0-9]+' "$f" | sed 's/.*=//')
  [ -n "$a" ] && echo "$(basename $f) begin=$((a/19200000))s took=$(( (b-a)/19200 ))ms"
done
echo "=== the loader tree"
U=$E/unixnu-build/uefi-fuxi
ls $U | head -30
git -C $U log --oneline -3 2>/dev/null | cut -c1-90
echo "=== watchdog and exit boot services in the loader sources"
grep -rIn -E 'SetWatchdogTimer|WatchdogTimer|ExitBootServices|WDOG|Watchdog' $U $E/unixnu-build/unixnu --include='*.c' --include='*.h' --include='*.inf' --include='*.dsc' --include='*.fdf' --include='*.dec' --include='*.rs' --include='*.py' --include='*.toml' 2>/dev/null | grep -v -E '/(Edk2|edk2|MdePkg|MdeModulePkg|BaseTools|CryptoPkg|ShellPkg|\.git)/' | cut -c1-175 | head -40
echo "=== notes on the early stage"
grep -n -i -E 'exitbootservices|watchdog|wdog|uefi.*(hang|stuck|卡)' $E/unixnu-build/fuxi/AGENTS.md $E/unixnu-build/fuxi/BUILD-PROGRESS.md 2>/dev/null | cut -c1-170 | head -20
