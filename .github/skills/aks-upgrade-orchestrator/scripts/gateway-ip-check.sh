#!/usr/bin/env bash
set -uo pipefail

usage() {
  printf 'Usage: %s RESOURCE_GROUP APPLICATION_GATEWAY EXPECTED_IP absent|present OUTPUT_DIR\n' "$0" >&2
}

if [[ $# -ne 5 ]]; then
  usage
  exit 2
fi

resource_group=$1
application_gateway=$2
expected_ip=$3
expected_state=$4
output_dir=$5
mkdir -p "$output_dir"

backend_file="$output_dir/application-gateway-backend-ips.json"
az network application-gateway show \
  --resource-group "$resource_group" \
  --name "$application_gateway" \
  --query 'backendAddressPools[].backendAddresses[].ipAddress' \
  --output json >"$backend_file" 2>"$output_dir/az-error.txt"
query_status=$?

observed_state=unknown
if [[ "$query_status" -eq 0 ]]; then
  if jq -e --arg ip "$expected_ip" 'any(.[]?; . == $ip)' "$backend_file" >/dev/null; then
    observed_state=present
  else
    observed_state=absent
  fi
fi

status=BLOCKED
if [[ "$query_status" -eq 0 && "$observed_state" == "$expected_state" ]]; then
  status=PASS
fi

jq -n \
  --arg resource_group "$resource_group" \
  --arg application_gateway "$application_gateway" \
  --arg expected_ip "$expected_ip" \
  --arg expected_state "$expected_state" \
  --arg observed_state "$observed_state" \
  --arg status "$status" \
  --arg observed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{workflow:"aks-upgrade-orchestrator",stage:"gateway-ip-check",status:$status,resource_group:$resource_group,application_gateway:$application_gateway,expected_ip:$expected_ip,expected_state:$expected_state,observed_state:$observed_state,observed_at:$observed_at,evidence:["application-gateway-backend-ips.json","az-error.txt"],blocking_findings:(if $status == "PASS" then [] else ["Observed Application Gateway state does not match the requested state; inspect evidence."] end),next_action:(if $status == "PASS" then "Ask permission before the next stage." else "Stop and resolve the traffic-routing discrepancy." end)}' >"$output_dir/stage.json"

if [[ "$status" == "PASS" ]]; then
  exit 0
fi
exit 1
