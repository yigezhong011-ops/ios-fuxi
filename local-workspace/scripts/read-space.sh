#!/bin/bash
# Read-only: what fills WSL, and what's left of the old iOS 16 line.
du -xsh /root/* /root/.[a-z]* /opt/* /home/* /tmp /var/cache 2>/dev/null | sort -h | tail -16
echo ---
du -xsh /root/fuxi/* 2>/dev/null | sort -h | tail -12
echo ---
ls -la /root/hakios-xnu-kernel 2>/dev/null | cut -c24- | head -14
du -sh /root/hakios-xnu-kernel/sysimage/* 2>/dev/null | head
ls -la /mnt/e/DSH-Fuxi/ipsw /mnt/e/DSH-Fuxi/kernel-inject /mnt/e/DSH-Fuxi/gles-stack /mnt/e/DSH-Fuxi/known-good /mnt/e/DSH-Fuxi/backup-gpu-first-light 2>/dev/null | cut -c24- | head -40
