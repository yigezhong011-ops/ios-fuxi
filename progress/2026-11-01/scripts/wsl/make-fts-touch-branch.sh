#!/bin/bash
# Branch fts-touch of our format-1 device repository (yigezhong011-ops/unixnu-fuxi, from old):
# replace the Novatek touch probe with OddlyLabs' ST FTM5 probe. Everything else stays as on old,
# the tree whose kernel reaches bsd_init on this phone.
#   package/FuxiTouchProbe.cpp, FuxiTouchBoard.h, QcomRpmh.*, SmmuBypass.h  <- OddlyLabs/unixnu-fuxi 77c0a03
#   package/FtsProtocol.*, FtsTouchCore.*                                   <- OddlyLabs/FuxiFtsTouch
#   package/GeniSpi.*                                                       <- UniXNU/QcomGeniSpi eac47ba
# The package lands in kits/sheng, ahead of drivers/NativeGeniSpi on the include path.
set -euo pipefail
cd /root/fuxi/fork-device
[ -z "$(git status --porcelain)" ] || { echo "fork-device has local changes"; git status --short; exit 1; }
git switch old
git switch -c fts-touch
cp /root/fuxi/fuxi-ours/package/{FuxiTouchProbe.cpp,FuxiTouchBoard.h,QcomRpmh.c,QcomRpmh.h,SmmuBypass.h} package/
cp /root/fuxi/FuxiFtsTouch/{FtsProtocol.c,FtsProtocol.h,FtsTouchCore.c,FtsTouchCore.h} package/
cp /root/fuxi/QcomGeniSpi/{GeniSpi.c,GeniSpi.h} package/

python3 - <<'PY'
from pathlib import Path
p = Path('scripts/build-native-legacy-display.py')
t = p.read_text()
old_cpp = "touch_cpp=ROOT/'kits/sheng/TouchProbe.cpp';touch_cpp_obj=touch_dir/'TouchProbe.o'"
new_cpp = "touch_cpp=ROOT/'kits/sheng/FuxiTouchProbe.cpp';touch_cpp_obj=touch_dir/'FuxiTouchProbe.o'"
old_fw = "print(run(['python3',ROOT/'scripts/gen-touch-firmware.py'],text=True),end='')\n"
old_c = ("touch_c=[ROOT/'drivers/NativeGeniSpi/GeniSpi.c',ROOT/'drivers/NativeNovatekTouch/NvtProtocol.c',\n"
         "         ROOT/'drivers/NativeNovatekTouch/NvtTouchCore.c',ROOT/'build/native-touch/NvtFirmware.c']")
new_c = ("# fuxi: ST FTM5 (OddlyLabs FuxiTouchProbe) instead of sheng's Novatek NT36532E; no firmware blob.\n"
         "touch_c=[ROOT/'kits/sheng/GeniSpi.c',ROOT/'kits/sheng/FtsProtocol.c',ROOT/'kits/sheng/FtsTouchCore.c',\n"
         "         ROOT/'kits/sheng/QcomRpmh.c']")
for a in (old_cpp, old_fw, old_c):
    assert t.count(a) == 1, a
t = t.replace(old_cpp, new_cpp).replace(old_fw, '').replace(old_c, new_c)
p.write_text(t)

b = Path('board.toml')
t = b.read_text()
# fuxi-touch=4: rails, clocks, pins, SPI, chip id, then interrupts and contacts; each stage's row goes to the
# diagnostic page (native_touch_rows). sheng-log / sheng-data-persist write windows at the end of userdata: left out
# while we suspect a storage write damaged slot a.
for arg in ('  "sheng-log=1",\n', '  "sheng-data-persist=2",\n'):
    assert t.count(arg) == 1, arg
    t = t.replace(arg, '')
anchor = '  "qcom-usb-debug=1",\n'
assert t.count(anchor) == 1
t = t.replace(anchor, anchor + '  "fuxi-touch=4",\n')
b.write_text(t)
PY

git add -A package scripts/build-native-legacy-display.py board.toml
git -c user.name=yigezhong011-ops -c user.email=yigezhong011-ops@users.noreply.github.com commit -q -m \
  "touch: use the ST FTM5 probe (OddlyLabs FuxiTouchProbe) instead of Novatek

fuxi's controller is an ST FingerTip FTM5 (id 36 40), not sheng's NT36532E.
FuxiTouchProbe exports the same native_touch_* interface, so HidInputProbe
and the diagnostic page read it unchanged. Boot with fuxi-touch=4; drop
sheng-log and sheng-data-persist for now."
git show --stat HEAD | tail -20
git push origin fts-touch
