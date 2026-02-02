# Runbook Examples

Complete examples of different runbook types following HMCTS conventions.

## Example 1: AKS Patching Runbook

**File**: `source/monitoring/patching-prometheus-operator.html.md.erb`

```erb
---
title: Prometheus Operator Patching
last_reviewed_on: 2026-02-02
review_in: 12 months
weight: 40
---

# <%= current_page.data.title %>

This runbook covers patching Prometheus Operator across AKS clusters.

## Prerequisites

- CFT and SDS AKS cluster access
- kubectl configured
- Access to hmcts GitHub repos
- Prometheus Operator knowledge

## When to Use This Guide

- Renovate creates update PR
- Security vulnerabilities require patching
- New features needed

## Planning

1. Review [release notes](https://github.com/prometheus-operator/prometheus-operator/releases)
2. Check for breaking changes
3. Review renovate PRs:
   - [CFT](https://github.com/hmcts/cnp-flux-config/pulls?q=prometheus-operator)
   - [SDS](https://github.com/hmcts/sds-flux-config/pulls?q=prometheus-operator)

## Environment Order

1. Sbox, 2. Ptlsbox, 3. ITHC, 4. Preview, 5. Demo, 6. Perftest, 7. AAT, 8. Production, 9. PTL

## Procedure

### Step 1: Pre-patch Check

```command
kubectl config current-context
kubectl get deploy -n monitoring prometheus-operator
```

### Step 2: Update Flux Config

#### CFT Environments
- [Example PR](https://github.com/hmcts/cnp-flux-config/pull/XXXXX)

#### SDS Environments
- [Example PR](https://github.com/hmcts/sds-flux-config/pull/XXXXX)

### Step 3: Monitor Deployment

```command
kubectl get hr -n monitoring prometheus-operator -w
```

## Verification

- [ ] Operator pod running
- [ ] No CrashLoopBackOff
- [ ] ServiceMonitors scraped
- [ ] Prometheus UI accessible
- [ ] Grafana shows data

## Rollback

```command
helm history prometheus-operator -n monitoring
helm rollback prometheus-operator [REVISION] -n monitoring
```

## Known Issues

### ServiceMonitor CRDs Not Updated

Check CRD version:
```command
kubectl get crd servicemonitors.monitoring.coreos.com -o yaml
```

May need manual CRD update.

## Related Documentation

- [Prometheus Grafana Example](patching-prometheus-grafana-example.html)
- [AKS Patching Apps](../aks/patching-aks-apps.html)
```

---

## Example 2: Troubleshooting Guide

**File**: `source/network/troubleshooting-appgw-502.html.md.erb`

```erb
---
title: Troubleshooting Application Gateway 502 Errors
last_reviewed_on: 2026-02-02
review_in: 12 months
weight: 25
---

# <%= current_page.data.title %>

Diagnose and resolve 502 Bad Gateway errors from Azure Application Gateway.

## Prerequisites

- Azure Portal access
- AKS cluster access
- kubectl configured

## Symptoms

- HTTP 502 responses
- Intermittent connectivity
- Services unreachable

## When to Use

- App Gateway returns 502
- Health probes failing
- After cluster upgrades

## Diagnostic Steps

### Step 1: Check Backend Health

Azure Portal → Application Gateway → Backend Health
Note any "Unhealthy" backends.

### Step 2: Verify Backend Pool IPs

```command
kubectl get svc -n ingress traefik -o wide
```

Compare with App Gateway backend pool IPs.

### Step 3: Test Direct Connectivity

```command
kubectl port-forward -n ingress svc/traefik 8080:80
curl http://localhost:8080/health
```

### Step 4: Check Cluster Health

```command
kubectl get pods -A | grep -v Running
kubectl logs -n ingress -l app=traefik --tail=100
```

## Common Resolutions

### Resolution 1: Update Backend Pool

After upgrade, IPs may change:

1. Get LB IP: `kubectl get svc -n ingress traefik`
2. Update App Gateway in Terraform
3. Run pipeline

**Examples**:
- [CFT](https://github.com/hmcts/azure-platform-terraform/pull/XXXXX)
- [SDS](https://github.com/hmcts/sds-azure-platform/pull/XXXXX)

### Resolution 2: Adjust Health Probes

Increase timeout if backend slow to respond.

### Resolution 3: Restart Ingress

```command
kubectl rollout restart deployment traefik -n ingress
```

## Verification

- [ ] Backend health "Healthy"
- [ ] No 502 errors
- [ ] Apps accessible
- [ ] Probes succeeding

## Prevention

- Monitor App Gateway metrics
- Document IP changes
- Automate backend updates

## Related Documentation

- [AKS Upgrades](../aks/upgrading-aks-clusters.html)
- [Network Overview](index.html)
```

---

## Example 3: Quick Reference

**File**: `source/oncall/kubectl-quick-ref.html.md.erb`

```erb
---
title: kubectl Quick Reference
last_reviewed_on: 2026-02-02
review_in: 12 months
weight: 15
---

# <%= current_page.data.title %>

Common kubectl commands for on-call troubleshooting.

## Prerequisites

- kubectl installed
- Cluster access
- RBAC permissions

## Cluster Context

```command
# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context cft-aat-00-aks

# Current context
kubectl config current-context
```

## Pod Operations

```command
# All pods
kubectl get pods -A

# Filter by status
kubectl get pods -A | grep -v Running

# Pod details
kubectl describe pod {pod-name} -n {namespace}

# Logs
kubectl logs {pod-name} -n {namespace}
kubectl logs -f {pod-name} -n {namespace}
```

## Helm Releases

```command
# All releases
kubectl get hr -A

# Failed releases
kubectl get hr -A | grep False

# Rollback
helm rollback {release-name} -n {namespace}
```

## Node Operations

```command
# List nodes
kubectl get nodes

# Node details
kubectl describe node {node-name}

# Drain node
kubectl drain {node-name} --ignore-daemonsets
```

## Troubleshooting Queries

```command
# Not running pods
kubectl get pods -A | awk '!/(Running|Succeeded)/'

# CrashLoopBackOff
kubectl get pods -A | grep CrashLoopBackOff

# PDBs with 0 disruptions
kubectl get pdb -A -o json | jq -r '.items[] | select(.status.disruptionsAllowed==0)'
```

## Useful Aliases

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
```

## Related Documentation

- [On-call Procedures](index.html)
- [AKS Troubleshooting](../aks/known-issues.html)
```

---

## Example 4: Index Page

**File**: `source/FinOps/index.html.md.erb`

```erb
---
title: Financial Operations (FinOps)
weight: 45
---

# <%= current_page.data.title %>

Runbooks for managing Azure costs and resource optimization.

## Contents

- Cost monitoring and alerting
- Resource optimization
- Budget management
- Commitment-based discounts
- Cost allocation
- Waste identification

## Related Sections

- [Terraform](../Terraform/index.html)
- [AKS](../aks/index.html)
- [Monitoring](../monitoring/index.html)
```

---

## Tips for Success

### Be Specific
❌ "Create runbook about AKS"
✅ "Create upgrade procedure for AKS node pools"

### Include Context
- Target environment (CFT/SDS/both)
- Document type (troubleshooting, procedure, reference)
- Expected audience

### Customize Generated Content
- Add specific cluster names
- Include actual PR links
- Add environment notes
- Test all commands

### Iterate
- "Add rollback section"
- "Include CFT examples"
- "Add common error troubleshooting"
