#!/bin/bash
# Finish the GPU plugin build: push the workflow, dispatch the plugin-only CI, retry when no runner takes the job, then
# build the test images. It never flashes anything and never touches the phone.
#   deepseek-gpu.sh status             recent runs of fuxi-gpu.yml
#   deepseek-gpu.sh run                push + dispatch + wait + install (long: start it with nohup, see the handoff)
#   deepseek-gpu.sh install <run-id>   only build t50-mine-gpu-fix.img and t36-bl2-gpu-fix.img from a finished run
# Exit: 0 images built; 2 real CI failure (the first error is printed); 3 no runner on any try; 4 install failed.
set -uo pipefail
TOKEN=$(tr -d '\r\n ' < /mnt/e/DSH-Fuxi/token2.txt)
API=https://api.github.com/repos/yigezhong011-ops/unixnu-ci
WF=$API/actions/workflows/fuxi-gpu.yml
P=.github/workflows/fuxi-gpu.yml
UNIXNU=793d6bddf7       # has AdrenoMetal bridge patch 0020, same NativeAdrenoABI.h as t36; do not use a newer one
W=/mnt/e/DSH-Fuxi/dump/wsl
H=(-H "Authorization: Bearer $TOKEN" -H 'Accept: application/vnd.github+json')

latest_run() {
  curl -fsSL "${H[@]}" "$WF/runs?per_page=1" | python3 -c 'import json,sys; r=json.load(sys.stdin)["workflow_runs"]; print(r[0]["id"] if r else 0)'
}

push_workflow() {
  local sha
  curl -fsSL "${H[@]}" -H 'Accept: application/vnd.github.raw' "$API/contents/$P" > /tmp/wf-remote.yml || return 1
  if tr -d '\r' < /mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml | cmp -s - /tmp/wf-remote.yml; then echo "workflow 已是最新"; return 0; fi
  sha=$(curl -fsSL "${H[@]}" "$API/contents/$P" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])') || return 1
  python3 - "$sha" > /tmp/wf-put.json <<'EOF'
import base64, json, sys
print(json.dumps({'message': 'ci: choose the macOS runner at dispatch',
                  'sha': sys.argv[1],
                  'content': base64.b64encode(open('/mnt/e/DSH-Fuxi/ci/fuxi-gpu.yml', 'rb').read().replace(b'\r\n', b'\n')).decode()}))
EOF
  curl -fsSL -X PUT "${H[@]}" "$API/contents/$P" -d @/tmp/wf-put.json >/dev/null || return 1
  echo "workflow 已推送"; sleep 10
}

# Prints the new run id.
dispatch() {
  local before full now
  before=$(latest_run) || return 1
  full=$(curl -fsSL "${H[@]}" "https://api.github.com/repos/UniXNU/UniXNU/commits/$UNIXNU" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])') || return 1
  curl -fsSL -X POST "${H[@]}" "$WF/dispatches" \
    -d "{\"ref\":\"main\",\"inputs\":{\"unixnu_ref\":\"$full\",\"build_kernel\":\"false\",\"runner\":\"$1\"}}" || return 1
  for _ in $(seq 1 30); do
    sleep 10
    now=$(latest_run) || continue
    [ "$now" != "$before" ] && { echo "$now"; return 0; }
  done
  return 1
}

# Prints "<conclusion> <steps that ran>" once the run is finished (at most 6 h, the job's own timeout).
wait_run() {
  local s
  for _ in $(seq 1 180); do
    s=$(curl -fsSL "${H[@]}" "$API/actions/runs/$1" | python3 -c 'import json,sys; print(json.load(sys.stdin)["status"])') || s=
    [ "$s" = completed ] && break
    sleep 120
  done
  curl -fsSL "${H[@]}" "$API/actions/runs/$1/jobs" | python3 -c '
import json, sys
jobs = json.load(sys.stdin)["jobs"]
j = jobs[0] if jobs else {"conclusion": "cancelled", "steps": []}
print(j["conclusion"], len([s for s in j["steps"] if s["conclusion"] not in (None, "skipped")]))'
}

install() {
  local rc=0 b
  for b in t50-mine t36-bl2; do
    if bash "$W/install-gpu-addon.sh" "$1" "$b"; then
      echo "$b: /mnt/e/DSH-Fuxi/$b-gpu-fix.img"; ls -l "/mnt/e/DSH-Fuxi/$b-gpu-fix.img"
    else
      echo "$b 失败，日志 /root/fuxi/install-gpu-$b.log："; tail -25 "/root/fuxi/install-gpu-$b.log"; rc=4
    fi
  done
  return $rc
}

# Files the workflow reads from its own repository (ci/patches). A normal commit per changed file, no force.
push_patches() {
  local f n remote sha
  for f in /mnt/e/DSH-Fuxi/ci/patches/*; do
    n=ci/patches/$(basename "$f")
    remote=/tmp/remote-$(basename "$f")
    if curl -fsSL "${H[@]}" -H 'Accept: application/vnd.github.raw' "$API/contents/$n" > "$remote" 2>/dev/null && cmp -s "$f" "$remote"; then
      echo "$n 已是最新"; continue
    fi
    sha=$(curl -fsSL "${H[@]}" "$API/contents/$n" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])' || true)
    python3 - "$f" "$n" "$sha" > /tmp/put-patch.json <<'EOF'
import base64, json, sys
body = {'message': 'ci: add ' + sys.argv[2], 'content': base64.b64encode(open(sys.argv[1], 'rb').read()).decode()}
if sys.argv[3]:
    body['sha'] = sys.argv[3]
print(json.dumps(body))
EOF
    curl -fsSL -X PUT "${H[@]}" "$API/contents/$n" -d @/tmp/put-patch.json >/dev/null || return 1
    echo "$n 已推送"
  done
}

case "${1:-}" in
status)
  curl -fsSL "${H[@]}" "$WF/runs?per_page=8" | python3 -c '
import json, sys
for r in json.load(sys.stdin)["workflow_runs"]:
    print(r["id"], r["status"], r["conclusion"], r["run_started_at"], r["updated_at"], r["html_url"])'
  ;;
install)
  install "${2:?需要 run id}"; exit $?
  ;;
run)
  push_patches || { echo "补丁推送失败"; exit 1; }
  push_workflow || { echo "workflow 推送失败"; exit 1; }
  # macos-26 is the image every earlier build ran on; macos-15 only when it gets no machine.
  for R in macos-26 macos-26 macos-26 macos-15 macos-15; do
    echo "=== $(date) 触发 runner=$R"
    RUN=$(dispatch "$R") || { echo "触发失败，5 分钟后再试"; sleep 300; continue; }
    echo "run $RUN  https://github.com/yigezhong011-ops/unixnu-ci/actions/runs/$RUN"
    C=$(wait_run "$RUN")
    echo "$(date) 结果: $C"
    case "$C" in
      success*) install "$RUN"; exit $? ;;
      "cancelled 0") echo "没有分配到机器（The job was not acquired by Runner），10 分钟后重试"; sleep 600 ;;
      *) echo "CI 真的失败了（runner=$R）。第一处错误："
         bash /root/fuxi/cfe.sh "$RUN"
         echo "完整日志: /root/fuxi/ci-job.log"
         exit 2 ;;
    esac
  done
  echo "5 次都没有分配到机器"; exit 3
  ;;
*)
  sed -n 2,7p "$0"; exit 1
  ;;
esac
