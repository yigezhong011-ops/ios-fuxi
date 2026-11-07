#!/bin/bash
# Upstream notes and code for wallpaper, widgets and the client slots. Read-only.
A=/root/fuxi/src-adrenometal; U=/root/fuxi/src-unixnu; R=793d6bddf7ea90678e3a61e2b2bd4350e5fdce16
echo "=== AdrenoMetal 390b0ab (first-frame wallpaper isolation)"; git -C $A show --stat --format='%B' 390b0ab | cut -c1-200 | head -30
git -C $A show 390b0ab --format= | grep -E '^\+' | cut -c2-260 | head -60
echo "=== 722b9c1"; git -C $A show --stat --format='%B' 722b9c1 | cut -c1-220 | head -30
echo "=== 8c1ea13"; git -C $A show --stat --format='%B' 8c1ea13 | cut -c1-220 | head -40
echo "=== 10d0619"; git -C $A show 10d0619 --format= | grep -E '^\+' | cut -c2-260 | head -40
echo "=== make-wallpaper-overlay.py at 793d"; git -C $U show $R:scripts/make-wallpaper-overlay.py | sed -n 1,40p | cut -c1-200
echo "=== UniXNU f477f79"; git -C $U show --stat --format='%B' f477f79 | cut -c1-200 | head -20
echo "=== UniXNU 0ca54a3"; git -C $U show --stat --format='%B' 0ca54a3 | cut -c1-200 | head -20
echo "=== DeepSeek wallpaper notes"; sed -n 1,50p /root/fuxi/ios-fuxi/progress/2026-11-03/README.md | cut -c1-200
