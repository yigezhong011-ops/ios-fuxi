#!/bin/bash
# fts-touch: add package/FuxiTouchCompat.c to the touch archive (symbols the first CI link, run 41292911837,
# reported undefined), commit and push.
set -euo pipefail
cd /root/fuxi/fork-device
git switch fts-touch
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/FuxiTouchCompat.c > package/FuxiTouchCompat.c
python3 - <<'PY'
from pathlib import Path
p = Path('scripts/build-native-legacy-display.py')
t = p.read_text()
old = "         ROOT/'kits/sheng/QcomRpmh.c']"
new = "         ROOT/'kits/sheng/QcomRpmh.c',ROOT/'kits/sheng/FuxiTouchCompat.c']"
assert t.count(old) == 1
p.write_text(t.replace(old, new))
PY
git add package/FuxiTouchCompat.c scripts/build-native-legacy-display.py
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
  "touch: define the BootLog stroke statistics and the owner-root checkpoint

The first link with the FTS probe left native_touch_strokes, _stroke_count,
_extent (BootLog.c) and native_owner_root_accepted_checkpoint (bsd_init,
zzz-boot-progress.patch) undefined."
git log --oneline -3
git push origin fts-touch
