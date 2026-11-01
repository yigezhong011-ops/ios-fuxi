#!/bin/bash
# Which boot arguments of the t32 kernel select the PMIC keys (sheng's SPMI PON/GPIO path), and their nearby strings.
K=/root/fuxi/t32/kernel.macho
echo "== boot-arg-like strings around buttons / keys / pon"
grep -a -o -E '(sheng|fuxi|native|offline)-[a-z0-9-]*(button|key|pon|spmi|pmic|gpio|vol|hid)[a-z0-9-]*' "$K" | sort -u
echo "== format strings mentioning buttons / pon / ppid"
grep -a -o -E '[ -~]{0,40}(button|BTN|ppid|PON |pon:|keypad)[ -~]{0,80}' "$K" | sort -u | head -30
