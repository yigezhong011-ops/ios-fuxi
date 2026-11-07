#!/bin/bash
# Look for UniXNU-family code that sends DCS brightness over a Qualcomm DSI host (read-only)
tr -d '\r' < /mnt/e/DSH-Fuxi/dump/wsl/gh-code-search.py > /root/fuxi/cs.py
for q in 'DSI_CMD_DMA_CTRL' 'PaganiPanel' 'dcs brightness backlight-control' 'COMMAND_MODE_DMA_CTRL' 'native_backlight_stats' 'AppleARMBacklight backlight-control DSI'; do
    echo "### $q"
    python3 /root/fuxi/cs.py "$q" | head -20
    sleep 3
done
