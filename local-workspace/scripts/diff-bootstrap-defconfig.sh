#!/bin/bash
# How the user's fork made a bootstrap defconfig for the two-pass build: diff it against its full GPU defconfig, and
# compare that full defconfig with ljhhkx529 old's fuxi_full_defconfig.
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
raw() { curl -fsSL -H "Authorization: Bearer $TOKEN" "https://raw.githubusercontent.com/$1"; }
cd /root/fuxi && mkdir -p defc && cd defc
raw yigezhong011-ops/unixnu-fuxi/fts-touch/configs/fuxi_gpu_bootstrap_defconfig > boot
raw yigezhong011-ops/unixnu-fuxi/fts-touch/configs/fuxi_gpu_defconfig > gpu
raw ljhhkx529/unixnu-fuxi/old/configs/fuxi_full_defconfig > old-full
echo "### bootstrap vs gpu (fork)"; diff <(grep -v '^#' boot | sort) <(grep -v '^#' gpu | sort)
echo "### fork gpu vs old full"; diff <(grep -v '^#' gpu | sort) <(grep -v '^#' old-full | sort)
