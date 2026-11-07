#!/bin/bash
# Read the same-device fork's identity and wallpaper work. Clone only; nothing from it is executed.
R=/root/fuxi/ref-sad-fuxi
[ -d "$R/.git" ] || git clone -q -b old https://github.com/SadNutWall/unixnu-fuxi "$R" || exit 1
cd "$R" || exit 1
git fetch -q origin
echo "== branch $(git rev-parse --abbrev-ref HEAD) $(git rev-parse --short HEAD)"
git log --since=2026-11-01 --no-merges --format='%h %ad %s' --date=short | cut -c1-110
for s in 'wallpaper overlay' 'iPhone15,2' 'panel brightness'; do
  c=$(git log --no-merges --format=%h -i --grep="$s" | head -1)
  [ -n "$c" ] || continue
  echo; echo "=== $s: $c"
  git log -1 --format='%b' "$c" | cut -c1-500 | head -30
  git show --stat --format= "$c" | cut -c1-100 | tail -20
done
c=$(git log --no-merges --format=%h -i --grep='wallpaper overlay' | head -1)
echo; echo "=== wallpaper overlay full diff"
git show --format= "$c" | cut -c1-190 | head -240
c=$(git log --no-merges --format=%h -i --grep='iPhone15,2' | head -1)
echo; echo "=== identity diff, wallpaper and product lines"
git show --format= "$c" | grep -E '^[-+]' | grep -i -E 'idiom|subtype|artwork|product|model|target|compatible|wallpaper|poster|home-button|memory-class|display-scale' | cut -c1-170 | head -50
echo; echo "=== Poster, RTC, HEVC anywhere in the fork"
git grep -n -I -i -E 'poster|wallpaper|IORTC|QcomPmicRtc|hvc1|VTCompression' -- . ':!*.json' | cut -c1-170 | head -30
echo; echo "=== differs from our tree"
for f in $(git show --name-only --format= "$(git log --no-merges --format=%h -i --grep='wallpaper overlay' | head -1)"); do
  [ -e "/mnt/e/DSH-Fuxi/unixnu-build/fuxi/$f" ] && echo "have $f" || echo "missing $f"
done
