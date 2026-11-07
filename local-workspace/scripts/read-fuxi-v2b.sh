#!/bin/bash
# Read-only: local copies named UniXNU-FUXI, and how V2 patches UniXNU.
set -u
echo '== local dirs'
find /mnt/e/DSH-Fuxi /root/fuxi -maxdepth 3 -type d -iname '*unixnu*fuxi*' 2>/dev/null | head -20
find /mnt/e/DSH-Fuxi /root/fuxi -maxdepth 3 \( -type d -o -type f \) -iname '*unixnu*' 2>/dev/null | grep -v -E '/待删除/' | head -30
cd /root/fuxi/ref-unixnu-fuxi-bare || exit 1
V=V2
echo '== patches/manual/README.md'; git show $V:patches/manual/README.md | head -70
echo '== patches tree'; git ls-tree -r --name-only $V patches | head -60
echo '== patches/xnu/series'; git show $V:patches/xnu/series | head -40
echo '== board.toml'; git show $V:board.toml | head -70
echo '== build.yml unixnu lines'; git show $V:.github/workflows/build.yml | grep -n -i -E 'unixnu|repository:|ref:|patch|legacy|upload|artifact|macos|runs-on' | cut -c1-140 | head -50
echo '== AGENTS.md head'; git show $V:AGENTS.md | head -40 | cut -c1-200
echo '== gitmodules'; git show $V:.gitmodules
echo '== legacy abi'; git ls-tree -r --name-only $V | grep -i -E 'legacy|abi|canvas|statusbar'
git grep -n -i -E 'status.?bar|canvas|logical.?(size|width)' $V -- ':!facts' ':!docs' ':!evidence' 2>/dev/null | cut -c1-150 | head -30
