#!/bin/bash
# Read only: keyboard layout, Control Center and battery in the upstream docs, the sources and the other fuxi trees.
U=/root/fuxi/up-latest; B=origin/main; git -C $U fetch -q origin 2>/dev/null || true
X='docs/devices docs/porting docs/drivers :!docs/zh'
show() { git -C $U grep -n -iE "$1" $B -- docs/devices docs/porting docs/drivers ':!docs/zh' | sed "s#^$B:docs/##" | cut -c1-${2:-330} | head -${3:-22}; }
echo '== keyboard'; show 'keyboard|keycap|UIKeyboard|TextInput.{0,40}(layout|missing)|key(s)? (is|are) (missing|blank)' 340 22
echo; echo '== control center'; show 'control ?cent(er|re)|ControlCenter' 340 18
echo; echo '== status bar, fallback, screen size'; show '_UIStatusBar|rdar:45025538|fallback status|canvas|main-?screen|ArtworkDeviceSubType|DeviceSubType|screen-?class' 300 22
echo; echo '== battery'; show 'battery|AppleSmartBattery|IOPMPowerSource|fuel ?gauge|PMIC.{0,30}(charge|gauge)|charging|PowerSource' 320 30
echo; echo '== drivers in the tree that may be about it'; git -C $U ls-tree --name-only $B drivers/ | grep -iE 'batt|charg|fuel|pmic|power|spmi|smb|adsp|glink|pmic'
python3 -I -c "
import json
try:
    for r in json.load(open('/tmp/ux-repos.json')):
        n=r['name']
        if any(k in n.lower() for k in ('batt','charg','fuel','pmic','power','glink','spmi')): print('repo',n,r['pushed_at'],(r['description'] or '')[:80])
except Exception as e: print(e)"
echo; echo '== other fuxi trees'
for r in /root/fuxi/ref-fuxi-v2 /root/fuxi/fuxi2 /root/fuxi/fuxi-oddly /root/fuxi/ref-sad-fuxi; do echo "-- $r"; git -C $r grep -n -iE 'battery|fuel.?gauge|keyboard|control ?center|canvas|1179|2556|subtype|phone_model' HEAD -- . | sed 's#^HEAD:##' | cut -c1-210 | head -12; done
echo; echo '== our ADT and battery nodes'
strings -n 5 /root/fuxi/t50-gpu7/kernel.macho 2>/dev/null | grep -iE 'AppleSmartBattery|IOPMPowerSource|BatteryPercent|CurrentCapacity|ExternalConnected' | head -8 | cut -c1-120
