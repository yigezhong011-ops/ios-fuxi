#!/bin/bash
# Clone UniXNU main and the t32 board repo (old) for the userdata build, check lzfse and the board's userdata table.
U=/root/fuxi/ux; D=/root/fuxi/ux-device
[ -d $U/.git ] || git clone -q --depth 1 https://github.com/UniXNU/UniXNU.git $U
[ -d $D/.git ] || git clone -q --depth 1 -b old https://github.com/ljhhkx529/unixnu-fuxi.git $D
git -C $U log -1 --format='UniXNU %h %cd'; git -C $D log -1 --format='device %h %cd'
command -v lzfse >/dev/null || apt-get install -y lzfse >/dev/null 2>&1
command -v lzfse && echo lzfse ok
grep -n -A10 '^\[userdata\]' $D/board.toml
grep -n 'root_match_volume_uuid' $D/board.toml
