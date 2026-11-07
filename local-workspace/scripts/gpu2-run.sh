#!/bin/bash
# Second GPU build (colour patch + prime list). Keeps the first images as *-gpu-fix1.img, then runs the CI and packs. Nothing is flashed.
E=/mnt/e/DSH-Fuxi
for b in t50-mine t36-bl2; do
  [ -f "$E/$b-gpu-fix1.img" ] || cp "$E/$b-gpu-fix.img" "$E/$b-gpu-fix1.img"
done
python3 - <<'EOF'
lines = open('/mnt/e/DSH-Fuxi/ci/patches/prime-list.txt').read().split()
bad = [l for l in lines if not l.startswith('/') or not l.endswith('.metallib')]
print('prime list', len(lines), 'bad', len(bad), bad[:5])
raise SystemExit(1 if bad else 0)
EOF
[ $? = 0 ] || exit 1
grep -rn -I -E 'ghp_|github_pat_|ce854c9a|FASTBOOT_SERIAL_REDACTED' $E/ci/patches $E/ci/fuxi-gpu.yml && { echo secret; exit 1; }
sed -i 's/\r$//' $E/dump/wsl/deepseek-gpu.sh $E/dump/wsl/deepseek-gpu-run.sh
bash -n $E/dump/wsl/deepseek-gpu.sh || exit 1
python3 -c 'import yaml; yaml.safe_load(open("/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml")); print("yaml ok")' || exit 1
bash $E/dump/wsl/deepseek-gpu-run.sh
tail -30 /root/fuxi/deepseek-gpu.log
