#!/usr/bin/env bash
set -uo pipefail

usage() {
  printf 'Usage: %s URL OUTPUT_DIR [EXPECTED_STATUS]\n' "$0" >&2
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 2
fi

url=$1
output_dir=$2
expected_status=${3:-200}
mkdir -p "$output_dir"

curl -sS -L --max-time 20 -o "$output_dir/response.body" \
  -w '{"status_code":%{http_code},"time_total_seconds":%{time_total},"size_bytes":%{size_download}}\n' \
  "$url" >"$output_dir/response.json" 2>"$output_dir/curl-error.txt"
curl_status=$?

actual_status=0
if [[ -s "$output_dir/response.json" ]]; then
  actual_status=$(jq -r '.status_code' "$output_dir/response.json" 2>/dev/null || printf '0')
fi

status=BLOCKED
if [[ "$curl_status" -eq 0 && "$actual_status" == "$expected_status" ]]; then
  status=PASS
fi

jq -n \
  --arg url "$url" \
  --arg expected_status "$expected_status" \
  --arg actual_status "$actual_status" \
  --arg status "$status" \
  --arg observed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{workflow:"aks-upgrade-orchestrator",stage:"functional-check",status:$status,url:$url,expected_status:$expected_status,actual_status:$actual_status,observed_at:$observed_at,evidence:["response.json","curl-error.txt"],blocking_findings:(if $status == "PASS" then [] else ["Functional endpoint did not return the expected status; inspect evidence."] end),next_action:(if $status == "PASS" then "Ask permission before the next stage." else "Stop and investigate the functional test failure." end)}' >"$output_dir/stage.json"

rm -f "$output_dir/response.body"

if [[ "$status" == "PASS" ]]; then
  exit 0
fi
exit 1
