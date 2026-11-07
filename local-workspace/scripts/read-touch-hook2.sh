#!/bin/bash
# Read-only: parse_verb's body for the enum values, and what qcom_usb_shot_capture does when a frame is already held.
R=/root/fuxi/ref-qcomxnuusbdebug/kernel; D=/root/fuxi/t50.dis
awk '$1>="fffffff00c074e6c:" && $1<="fffffff00c075040:"' "$D" | grep -E 'mov\s+w0|ret$|^fffffff00c074e6c|<_' | cut -c1-70 | head -30
sed -n 21,30p $R/QcomUsbControl.h
L=$(grep -n '^int qcom_usb_shot_capture\|qcom_usb_shot_capture(' $R/QcomUsbScreenshot.c | head -1 | cut -d: -f1); sed -n "$L,$((L+40))p" $R/QcomUsbScreenshot.c | cut -c1-100
sed -n 348,353p /mnt/e/DSH-Fuxi/unixnu-build/unixnu/drivers/Adreno740/NativeAdrenoSubmit.cpp | cut -c1-170
