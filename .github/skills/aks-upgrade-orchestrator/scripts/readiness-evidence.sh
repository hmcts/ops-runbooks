#!/usr/bin/env bash
set -uo pipefail

usage() {
  printf 'Usage: %s CONTEXT OUTPUT_DIR [TARGET_MINOR]\n' "$0" >&2
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 2
fi

context=$1
output_dir=$2
target_minor=${3:-unknown}
mkdir -p "$output_dir"

run_check() {
  local name=$1
  shift
  local output_file="$output_dir/$name.txt"
  "$@" >"$output_file" 2>&1
  local check_status=$?
  printf '%s\n' "$check_status" >"$output_dir/$name.rc"
  return "$check_status"
}

failed=0
run_check current_context kubectl config current-context || failed=1
run_check cluster_version kubectl version -o json || failed=1
run_check nodes kubectl get nodes -o wide || failed=1
run_check pods kubectl get pods --all-namespaces || failed=1
run_check helmreleases kubectl get hr --all-namespaces || failed=1
run_check pdbs kubectl get pdb --all-namespaces || failed=1

jq -n \
  --arg context "$context" \
  --arg target_minor "$target_minor" \
  --arg observed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson failed "$failed" \
  '{workflow:"aks-upgrade-orchestrator",stage:"readiness",status:(if $failed == 0 then "PASS" else "BLOCKED" end),cluster:$context,target_minor:$target_minor,observed_at:$observed_at,evidence:["current_context.txt","cluster_version.txt","nodes.txt","pods.txt","helmreleases.txt","pdbs.txt"],blocking_findings:(if $failed == 0 then [] else ["One or more read-only kubectl checks failed; inspect .txt and .rc files."] end),next_action:(if $failed == 0 then "Ask permission before the next stage." else "Resolve failed checks and rerun with a new output directory." end)}' >"$output_dir/stage.json"

exit "$failed"
