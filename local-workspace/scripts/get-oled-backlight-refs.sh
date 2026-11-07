#!/bin/bash
# Fetch OLED/DSI brightness references from other UniXNU ports (read-only) into E:\DSH-Fuxi\read\oled-bl
out=/mnt/e/DSH-Fuxi/read/oled-bl
mkdir -p "$out"
get() { python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-get-file.py "$1" "$2" "$3" "$out/$4" 2>&1 | tail -1; }
get UniXNU/UniXNU main docs/porting/display.md display.md
get lonzzi/UniXNU-houji main kernel/overlay/iokit/Kernel/arm/HoujiBacklight.inc houji-HoujiBacklight.inc
get Chengdong-Yu/UniXNU-pong main drivers/PongPower/PongBacklight.cpp pong-PongBacklight.cpp
get Chengdong-Yu/UniXNU-pong main drivers/PongPower/README.backlight.md pong-README.backlight.md
get FFT-infra/UniXNU-alioth main package/BacklightProbe.cpp alioth-BacklightProbe.cpp
get xiaoan919/UniXNU-ace6 main drivers/PaganiPanel/PaganiPanel.cpp ace6-PaganiPanel.cpp
get xiaoan919/UniXNU-ace6 main drivers/PaganiPanel/README.md ace6-PaganiPanel-README.md
echo "== houji tree (backlight/dsi/panel)"
python3 /mnt/e/DSH-Fuxi/dump/wsl/gh-grep-tree.py lonzzi/UniXNU-houji main 'backlight|dsi|panel|brightness' | head -30
ls -la "$out"
