---
name: aks-upgrade-orchestrator
description: 'Run a staged, approval-gated AKS upgrade workflow for HMCTS clusters. Use for AKS upgrade planning, readiness checks, Application Gateway removal and verification, health comparison, PDB handling, functional smoke tests, PR creation, and post-upgrade sign-off.'
argument-hint: '[cluster context, environment, target Kubernetes minor version, and optional functional endpoint]'
user-invocable: true
disable-model-invocation: false
---

# AKS Upgrade Orchestrator

Turn the AKS upgrade runbook into a chronological, evidence-driven workflow. Keep each stage's context small, use the bundled scripts for repeatable read-only checks, and preserve a human controller at every boundary.

## Non-negotiable rules

- Ask for explicit permission before starting the workflow and again before every stage transition.
- Never run a mutating `kubectl`, `az`, `helm`, Git, GitHub, Azure DevOps, or HTTP operation without naming it and receiving permission in the current conversation.
- Read-only checks may run automatically once the user has started the current stage.
- Do not infer that a pipeline, PR, Application Gateway change, or upgrade completed. Require evidence from the responsible system.
- Stop on a failed check, unexpected output, missing input, or ambiguous cluster/IP mapping.
- Use the user's existing local GitHub credentials only through `gh`; never request, print, or store tokens.
- Treat production as requiring the runbook's Change Request and notification prerequisites.
- Keep evidence in a timestamped run directory and report the same result schema on every run.

## Required inputs

Collect and confirm:

- cluster context and AKS resource group
- CFT or SDS, environment, and cluster slot (`00` or `01`)
- target Kubernetes minor version
- Application Gateway/load balancer details and the cluster frontend IP
- infrastructure repository and branch for the version/configuration PR
- Flux repository if PDB changes are needed
- functional smoke-test URL, or an explicitly approved endpoint such as Plum
- run directory for evidence

Do not guess a resource group, IP, active AAT cluster, production status, or endpoint. Resolve it with a read-only command and ask the controller to confirm.

## Stage contract

Every stage writes `stage.json` with this shape:

```json
{
  "workflow": "aks-upgrade-orchestrator",
  "stage": "readiness",
  "status": "PASS|FAIL|BLOCKED|PENDING_APPROVAL",
  "cluster": "context",
  "observed_at": "ISO-8601 timestamp",
  "evidence": ["relative/path or command output summary"],
  "blocking_findings": [],
  "next_action": "human-readable action"
}
```

A stage is complete only when its status is `PASS`, its evidence is saved, and the controller approves the next stage. Never overwrite evidence from an earlier attempt; use a new attempt directory.

## Workflow

### 0. Confirm scope and permission

Summarize the selected cluster, target version, environment, expected impact, commands to be run, and whether any later stage may require mutation. Ask: `Proceed with Stage 1 readiness checks?` Do not continue without an affirmative answer.

### 1. Normalize readiness

Run the existing `aks-upgrade-readiness-check` capability first when available. Normalize its variant output into the stage contract above. Preserve the raw result as evidence and map findings into: Kubernetes/API deprecations, node and control-plane health, workloads, HelmRelease status, PDB blockers, capacity, and version support.

Use [readiness-evidence.sh](./scripts/readiness-evidence.sh) for the local deterministic evidence set. It is read-only and independently executable. A failed HelmRelease, non-running workload, zero-disruption PDB relevant to an evictable workload, or unresolved command error is `BLOCKED`, not a warning. Ask permission before Stage 2.

### 2. Capture traffic and cluster baseline

Capture the current context, AKS version, nodes, pods, HelmReleases, PDBs, and the target cluster frontend IP. For paired clusters, identify which slot is active and verify the upgrade order. For AAT, the active Jenkins cluster must be upgraded last.

Run [readiness-evidence.sh](./scripts/readiness-evidence.sh) and save its JSON output. Compare post-upgrade evidence with this baseline rather than relying on memory. Ask permission before any Application Gateway change.

### 3. Remove the cluster from traffic through a reviewed PR

Prepare the smallest infrastructure PR that removes only the selected cluster IP, following the CFT/SDS repository used by the environment. Show the diff and use `gh auth status` to confirm the local human identity. Do not create the PR until the controller explicitly approves the exact repository, branch, diff, and PR title/body.

After approval, the controller may run `gh pr create` using local credentials and then the relevant pipeline. Wait for review, merge, and a successful pipeline as separate evidence points. Do not combine slot changes in one PR or pipeline run.

### 4. Verify traffic removal before upgrade

Resolve the cluster's frontend IP and verify it is absent from the effective Application Gateway/backend configuration and from an approved outbound observation. Use [gateway-ip-check.sh](./scripts/gateway-ip-check.sh), supplying the expected IP and a read-only Azure CLI query appropriate to the environment. A missing, stale, or contradictory result is `BLOCKED`.

Ask permission before Stage 5. This gate is mandatory even when the PR and pipeline report success.

### 5. Handle PDB blockers, if required

If Stage 1 found a blocking PDB, stop and identify the owning team. Prefer the documented `pdb_disruption_patch.sh prepare/apply` process or a reviewed Flux PR. Explain the exact mutation and rollback (`revert`) before asking permission. Record the PR, pipeline, and resulting cluster evidence. Never silently disable or edit a PDB.

Ask permission before the manual AKS upgrade.

### 6. Upgrade the cluster

The human controller performs the AKS version change in the Azure portal or approved operational path. Do not use Terraform to perform the initial version change when the runbook requires avoiding state issues. Record the before/after version and Azure operation evidence. On failure, stop and use the known-issues runbook; do not retry or rebuild without permission.

Ask permission before post-upgrade checks.

### 7. Post-upgrade health and functional verification

Run the deterministic evidence script again and compare it with the baseline. Verify nodes, pods, HelmReleases, PDBs, Kubernetes version, and any environment-specific Jenkins status. Then run [functional-check.sh](./scripts/functional-check.sh) against the approved endpoint. The functional check is additional to pod/HelmRelease health; health alone does not pass this stage.

A smoke test must record URL, status code, latency, timestamp, and response-size or approved identifying evidence. Do not log response bodies containing secrets or personal data. Ask permission before restore/PR creation.

### 8. Restore traffic and revert temporary changes

Prepare a separate reviewed PR to restore the cluster IP, and a separate PDB revert PR/operation where applicable. Require explicit approval before each PR and pipeline. After successful deployment, rerun [gateway-ip-check.sh](./scripts/gateway-ip-check.sh) to confirm the expected IP is present, then rerun health and functional checks.

For paired clusters, complete one slot fully before changing the other. Ask permission before final sign-off.

### 9. Final sign-off

Produce a concise report containing inputs, stage statuses, PR URLs, pipeline URLs, Azure operation IDs, baseline/post-upgrade comparison, functional-test result, unresolved risks, and the controller's approval. Mark the workflow `PASS` only when all mandatory stages pass and traffic restoration is verified. Otherwise mark it `BLOCKED` or `FAIL` with the exact next action.

## Command safety

The scripts in `./scripts/` are read-only. They require only tools stated in their usage output and do not depend on another script. Commands that can mutate state, including `gh pr create`, `az aks upgrade`, `kubectl apply/patch/delete`, Helm rollback, PDB apply/revert, and pipeline execution, must remain visible, separately approved controller actions.

## References

- [AKS upgrade runbook](../../../source/aks/upgrading-aks-clusters.html.md.erb)
- [AKS known issues](../../../source/aks/known-issues.html.md.erb)
- [Runbook contribution guidance](../../../source/Contribution-Guide/index.html.md.erb)
