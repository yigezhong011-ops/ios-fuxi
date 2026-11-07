#!/bin/bash
set -uo pipefail
echo "=== addon 里的 goodix / touch ==="
strings -a /root/insp-user/mnt/EFI/UniXNU/Payloads/kernel.macho.gpuaddon 2>/dev/null | grep -i 'goodix\|gt99\|touch\|novatek\|nvt' | sort -u | head -15 | cut -c1-120
echo
echo "=== scratch-data 里 ==="
strings -a /root/fuxi/pkg4/scratch-data.img 2>/dev/null | grep -i 'goodix\|touch' | head -8 | cut -c1-110
echo
echo "=== 内核里 touch 驱动名（完整）==="
strings -a /root/insp-user/kernel.macho 2>/dev/null | grep -E 'Native[A-Za-z]*Touch|Nvt|Goodix|GeniSpi|SpiTouch' | sort -u | head -15 | cut -c1-120
