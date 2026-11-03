#!/bin/bash
# Status tables and the GPU / USB / display lines of the other SM8550 records (fuxi-kkkpc, fuxi-mouse233, fuxi-oddlylabs, ishtar).
for s in fuxi-kkkpc fuxi-mouse233 fuxi-oddlylabs ishtar; do
  echo "########## $s"
  curl -fsSL "https://unixnu.com/zh/devices/$s" -o /root/fuxi/rec-$s.html || continue
  python3 - /root/fuxi/rec-$s.html <<'EOF'
import html, re, sys
t = open(sys.argv[1], encoding='utf-8').read()
t = re.sub(r'<script.*?</script>|<style.*?</style>', ' ', t, flags=re.S)
t = html.unescape(re.sub(r'<[^>]+>', '\n', t))
lines = [l.strip() for l in t.splitlines() if l.strip()]
# status table: "part" followed by a status word
st = [f'{a}={b}' for a, b in zip(lines, lines[1:]) if b in ('implemented', 'partial', 'planned', 'blocked', 'verified', 'not-started', 'in-progress')]
print('status:', ' '.join(st[:20]))
for l in lines:
    if re.search(r'(?i)\b(usb|dwc3|cdc|qcom-usb|adreno|metal|gpu addon|clients|verify_swap|sheng-setup|widget|wallpaper)\b', l) and 40 < len(l) < 600:
        print(' -', l[:400])
EOF
done
