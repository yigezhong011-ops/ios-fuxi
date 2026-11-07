#!/bin/bash
# Read-only: screenshot conditions, the fastboot verb, whether V2 registers a display provider, and whether V2 still needs the author's ABI file.
set -u
R=/root/fuxi/ref-unixnu-fuxi-bare; Q=/root/fuxi/ref-qcomxnuusbdebug; V=V2
cd "$Q" || exit 1
echo '== control-and-screenshot.md'; cut -c1-210 docs/control-and-screenshot.md | head -75
echo '== host verbs'; grep -n -i -E 'fastboot|add_parser|choices' scripts/xnu_usb_control.py | cut -c1-130 | head -15
cd "$R" || exit 1
echo '== V2 callers of the screenshot provider'
git grep -n -E 'qcom_usb_debug_register|register_framebuffer|FUXI_PANIC_FASTBOOT|fuxi-panic-fastboot' $V -- ':!drivers' | cut -c1-170 | head -15
echo '== V2 boot args with reset / ctl'; git grep -n -E 'qcom-usb-ctl|autoreset' $V -- board.toml configs scripts/fuxi-kernel-baseline.sh | cut -c1-150 | head
echo '== V2 graphics / display in archives'; git grep -n -i -E 'legacy|adreno|gpu|display' $V -- board.toml | cut -c1-130 | head -15
echo '== ABI commits'
for c in f9c7972 738c0ec; do git log -1 --format='--- %h %s%n%b' $c | cut -c1-220 | head -14; done
git grep -n 'mobile-graphics-legacy-abi' $V | cut -c1-170 | head -12
echo '== CI runners'; git show $V:.github/workflows/build.yml | grep -n -E 'runs-on|^  [a-z-]+:$' | head -14
echo '== local provider call'
grep -rn -E 'qcom_usb_debug_register|register_framebuffer' /mnt/e/DSH-Fuxi/unixnu-build/fuxi/package /mnt/e/DSH-Fuxi/unixnu-build/fuxi/patches 2>/dev/null | cut -c1-170 | head
