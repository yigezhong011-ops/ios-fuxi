#!/bin/bash
# Outline the Xiaomi panel nodes of the stock fuxi device tree: names, mode, size, timings and their frame rates,
# and which timings carry a switch command (the DCS sequence the Android driver sends to change refresh rate).
DTS=${1:-/root/fuxi/fuxi-live.dts}
FROM=${2:-34430}
TO=${3:-36500}
awk -v a="$FROM" -v b="$TO" '
NR >= a && NR <= b && (/panel-name|panel-type|framerate|timing@|panel-width|panel-height|timing-switch-command =|clockrate|dfps|\{$/) {
  s = $0; gsub(/^[ \t]+/, "", s)
  if (length(s) > 140) s = substr(s, 1, 140) "..."
  print NR ": " s
}' "$DTS"
