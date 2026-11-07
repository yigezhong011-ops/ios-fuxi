#!/bin/bash
# Read-only: other boards' vsync counters, the driver's strings in our kernel, and where the tick's source lives.
cd /root/fuxi
grep -rhoE '.{0,200}vsync hz=.{0,200}' up-latest/docs 2>/dev/null | cut -c1-420 | sort -u | head -6
grep -rhoE '.{0,240}(work-loop timer|vsync tick|refresh tick|sent=[0-9]{2,}).{0,240}' up-latest/docs/.vitepress/device-records/sheng.toml up-latest/docs/.vitepress/device-records/asteroids.toml up-latest/docs/.vitepress/device-records/alioth.toml 2>/dev/null | cut -c1-500 | sort -u | head -8
echo "== kernel strings"
grep -a -o -E '[ -~]{0,70}(vsync|VSync|Vsync|vblank|VBlank)[ -~]{0,70}' t50/kernel.macho | grep -v -E '^_|\.cpp' | sort -u | cut -c1-140 | head -40
echo "== source"
timeout 120 grep -rIl 'native_legacy_vsync_observed' /root/hakios-xnu-kernel /root/build /root/fuxi/*/patches /root/fuxi/ref-* 2>/dev/null | grep -v '\.git/' | head -8
ls /mnt/e/DSH-Fuxi/unixnu-build 2>/dev/null | head
