#!/bin/bash
# Where does the staged copy report, and what decides it may run? Read-only.
U=/root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
git -C $U show $R:patches/xnu/zzy-staged-system-apps.patch > /root/fuxi/staged.patch
sed -n 248,330p /root/fuxi/staged.patch | cut -c1-170
echo "== callers and order"
grep -n -E 'native_staged_apps_copy|native_staged_apps\(|native_owner_data_stage|^@@' /root/fuxi/staged.patch | cut -c1-150 | tail -14
echo "== board page row at the pin"
git -C $U grep -n -E 'native_staged_apps' $R -- kits package drivers 2>/dev/null | sed "s/^$R://" | cut -c1-190 | head
echo "== kernel symbols"
strings -a /root/fuxi/t50-mine/kernel.macho | grep -E 'native_staged|staged_apps|\.sheng-staged' | cut -c1-90 | sort -u | head -14
echo "== rows in the log carrying these numbers"
L=$(ls -d /root/fuxi/log-apps2/*/ | head -1)
grep -a -n -E '(^| )(SA|ST|APP|Apps|apps)[ =:]|owner.data|OD ' "$L/latest.txt" | cut -c1-170 | head -10
sed -n 1,40p "$L/latest.txt" | cut -c1-120
