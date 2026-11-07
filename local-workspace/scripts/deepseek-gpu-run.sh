#!/bin/bash
# deepseek-gpu.sh run with its output and exit code in /root/fuxi/deepseek-gpu.log.
cd /root/fuxi
bash /mnt/e/DSH-Fuxi/dump/wsl/deepseek-gpu.sh run > /root/fuxi/deepseek-gpu.log 2>&1
echo "exit=$?" >> /root/fuxi/deepseek-gpu.log
