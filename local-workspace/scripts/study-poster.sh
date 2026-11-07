#!/bin/bash
python3 /mnt/e/DSH-Fuxi/dump/wsl/study-poster.py
U=/root/fuxi/src-unixnu; A=/root/fuxi/src-adrenometal; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
echo "===== slot limit and grant list at the pin"
git -C $U show $R:patches/xnu/zzw-native-adreno-sandbox-grant.patch | grep -n -i -E 'PosterBoard|WidgetRenderer|backboardd|iconservices|Collections|grant' | cut -c1-170 | head -14
echo "===== upstream grant patch now"
git -C $U show origin/main:patches/xnu/zzw-native-adreno-sandbox-grant.patch | grep -n -i -E 'PosterBoard|WidgetRenderer|Collections|Preferences' | cut -c1-170 | head -10
git -C $U log $R..origin/main --format='%h %cI %s' -- patches/xnu/zzw-native-adreno-sandbox-grant.patch | cut -c1-120 | head
echo "===== commit 8c1ea13 poster single sample"
git -C $A show --stat --format='%h %s%n%b' 8c1ea13 | cut -c1-170 | head -40
echo "===== commit 722b9c1 wallpaper freeze"
git -C $A show --stat --format='%h %s%n%b' 722b9c1 | cut -c1-170 | head -30
echo "===== docs 390b0ab"
git -C $U show --format='%h %s%n%b' 390b0ab | grep -E '^[+]' | cut -c1-220 | head -40
echo "===== clientDevice in plugin"
git -C $A grep -n -E 'clientDevice|maxClients|kMaxClients|PosterBoard|WidgetRenderer' 7e0d3d2ebaecd736784de0baa09254b7f63bc150 | sed 's/^[0-9a-f]*://' | cut -c1-170 | head -16
A7=/root/fuxi/src-adreno740
git -C $A7 grep -n -E 'kMaxClients|maxClients|kClientSlots|ClientSlots|kIOReturnBusy' 759d646 -- NativeAdrenoPublish.cpp NativeAdrenoUserClient.cpp NativeAdrenoClient.cpp NativeAdrenoGpuContext.cpp | sed 's/^759d646://' | cut -c1-170 | head -14
