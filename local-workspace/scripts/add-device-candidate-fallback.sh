#!/bin/bash
# Keep the staged candidate in the device repository (which survives the tree
# rebuild) and let the display scripts fall back to it.
set -uo pipefail
DEV=/root/fuxi/fork-device
cd "$DEV" || exit 1
git checkout -q old && git reset -q --hard origin/old

# 1) take the tree's audit script as a device override
cp /root/ux3/fuxi/tree/scripts/audit-mobile-graphics-legacy.py scripts/audit-mobile-graphics-legacy.py

# 2) teach both scripts to look in the device repository
python3 - <<'PY'
from pathlib import Path

DEV_FALLBACK = '''
def _device_candidates(root):
    """Candidates staged in the device repository survive the tree rebuild."""
    import os
    from pathlib import Path as _Path
    base = os.environ.get('UNIXNU_DEVICE')
    if not base:
        return []
    directory = _Path(base) / 'build/xnu-prelink'
    return sorted(directory.glob('native-owner-ufs-cpu-desktop-*-candidate.macho'),
                  key=lambda f: f.stat().st_mtime) if directory.is_dir() else []
'''

# audit script: extend the fallback glob
p = Path('scripts/audit-mobile-graphics-legacy.py')
t = p.read_text()
old = "    later=sorted((ROOT/'build/xnu-prelink').glob('native-owner-ufs-cpu-desktop-*-candidate.macho'),key=lambda f:f.stat().st_mtime)"
new = old + "\n    later=later or _device_candidates(ROOT)"
if '_device_candidates' not in t:
    t = t.replace("from native_prelink import macho,backed_offset,exports",
                  "from native_prelink import macho,backed_offset,exports\n" + DEV_FALLBACK, 1)
    t = t.replace(old, new, 1)
    p.write_text(t)
    print('  audit 脚本已加设备仓库回退')

# display script: same fallback
p2 = Path('scripts/build-native-legacy-display.py')
t2 = p2.read_text()
old2 = "later=sorted((ROOT/'build/native-prelink').glob('native-owner-ufs-cpu-desktop-*-candidate.macho'),key=lambda f:f.stat().st_mtime)"
if '_device_candidates' not in t2:
    anchor = 'import json'
    t2 = t2.replace(anchor, anchor + '\n' + DEV_FALLBACK, 1)
    if old2 in t2:
        t2 = t2.replace(old2, old2 + "\n    later=later or _device_candidates(ROOT)", 1)
    p2.write_text(t2)
    print('  display 脚本已加设备仓库回退')
PY

git add -A
git -c user.name=dsh -c user.email=dsh@local commit -qm "scripts: fall back to candidates staged in the device repository"
git push -q origin old && echo "已推送"
