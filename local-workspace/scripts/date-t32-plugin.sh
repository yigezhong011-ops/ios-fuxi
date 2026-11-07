#!/bin/bash
# Date t32's plugin against upstream AdrenoMetal: which upstream log strings does it contain?
P=/root/fuxi/t32/addon-x/addons/NativeAdrenoMetal.bundle/NativeAdrenoMetal
U=/root/fuxi/upstream-am/NativeBridgeMetalFrontend.mm
for s in 'makes no linear' 'planes computed' 'texture over surface refused' 'single-sample' 'shadow' 'frozen' 'TB ' 'unaligned'; do
  printf '%-30s t32=%s upstream=%s\n' "$s" "$(grep -c -a -- "$s" $P)" "$(grep -c -- "$s" $U)"
done
echo "### upstream text around 'makes no linear'"
grep -rn 'makes no linear' /root/fuxi/upstream-am/ | cut -c1-220
echo "### t32 strings with 'linear image'"
strings -n 12 $P | grep -i 'linear image' | cut -c1-200 | head
echo "### upstream log tag in plugin (build date/rev?)"
strings -n 8 $P | grep -E '20(25|26)-[01][0-9]-[0-3][0-9]|rev [0-9a-f]{7}' | head
