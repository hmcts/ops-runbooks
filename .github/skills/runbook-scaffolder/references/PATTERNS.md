# Common Patterns Reference

Reusable patterns for HMCTS runbooks.

## Environment Lists

### Standard Progression

```markdown
## Environment Order

1. Sbox (cft-sbox-00-aks, cft-sbox-01-aks / ss-sbox-00-aks, ss-sbox-01-aks)
2. Ptlsbox (cft-ptlsbox-00-aks / ss-ptlsbox-00-aks)
3. ITHC (cft-ithc-00-aks, cft-ithc-01-aks / ss-ithc-00-aks, ss-ithc-01-aks)
4. Preview (cft-preview-00-aks / ss-dev-01-aks)
5. Demo (cft-demo-00-aks, cft-demo-01-aks / ss-demo-00-aks, ss-demo-01-aks)
6. Perftest (cft-perftest-00-aks, cft-perftest-01-aks / ss-test-00-aks, ss-test-01-aks)
7. AAT (cft-aat-00-aks, cft-aat-01-aks / ss-stg-00-aks, ss-stg-01-aks)
8. Production (prod-00-aks, prod-01-aks / ss-prod-00-aks, ss-prod-01-aks)
9. PTL (cft-ptl-00-aks / ss-ptl-00-aks)
```

### Compact List

```markdown
Upgrade order: Sbox → Ptlsbox → ITHC → Preview → Demo → Perftest → AAT → Production → PTL
```

## Pre-flight Checks

### Standard Health Check

```markdown
## Pre-upgrade Health Checks

Verify cluster context:
```command
kubectl config current-context
```

Check pod and HR status:
```command
kubectl get pods -A | wc -l > pods_total_count
kubectl get pods -A > pods_all_status
kubectl get pods -A | awk '!/(Running|Succeeded|Completed)/' > pods_not_running
kubectl get hr -A > hr_all_status
kubectl get hr -A | awk '/(Unknown|False)/' > hr_failed_status
kubectl get pdb -A > pdb_status
```

Investigate:
- Failed helm releases
- Pods in CrashLoopBackOff or ImagePullBackOff
- PDBs with disruptionsAllowed=0
```

### Minimal Check

```markdown
## Pre-checks

```command
kubectl config current-context
kubectl get nodes
kubectl get pods -A | grep -v Running
kubectl get hr -A | grep False
```
```

## kubectl Queries

### Common Filters

```markdown
# Not running or succeeded
kubectl get pods -A | awk '!/(Running|Succeeded|Completed)/'

# CrashLoopBackOff
kubectl get pods -A | grep CrashLoopBackOff

# ImagePullBackOff
kubectl get pods -A | grep ImagePullBackOff

# Evicted pods
kubectl get pods -A | grep Evicted

# Failed helm releases
kubectl get hr -A | awk '!/(True)/'

# PDBs with 0 disruptions allowed
kubectl get pdb -A -o json | jq -r '.items[] | select(.status.disruptionsAllowed==0) | {namespace: .metadata.namespace, name: .metadata.name}'
```

## Helm Operations

### Standard Commands

```markdown
# List releases
helm list -n {namespace}

# Release history
helm history {release-name} -n {namespace}

# Rollback to previous
helm rollback {release-name} -n {namespace}

# Rollback to specific version
helm rollback {release-name} {revision} -n {namespace}
```

## PR Example Formats

### With Context

```markdown
Create a PR to update the configuration:

**CFT Example**:
- [Update Flux version](https://github.com/hmcts/cnp-flux-config/pull/12345)

**SDS Example**:
- [Update Flux version](https://github.com/hmcts/sds-flux-config/pull/6789)
```

### Inline

```markdown
Update the configuration ([CFT example](https://github.com/hmcts/cnp-flux-config/pull/12345), [SDS example](https://github.com/hmcts/sds-flux-config/pull/6789))
```

### Simple List

```markdown
Example PRs:
- [CFT](https://github.com/hmcts/cnp-flux-config/pull/12345)
- [SDS](https://github.com/hmcts/sds-flux-config/pull/6789)
```

## Change Request Notices

### Standard Notice

```erb
<%= warning_text('A Change Request must be raised 2-3 days before performing this procedure in Production via <a href="https://mojcppprod.service-now.com/navpage.do">Service Now</a>') %>
```

### Custom Notice

```erb
<%= warning_text('If the <code>pdb</code> allows 0 disruptions, do not proceed with the cluster upgrade until pods are running.') %>
```

## Verification Checklists

### Deployment Verification

```markdown
## Verification

- [ ] Component pods running
- [ ] No CrashLoopBackOff errors
- [ ] Services accessible
- [ ] Health checks passing
- [ ] No alerts firing
- [ ] Logs show no errors
```

### Upgrade Verification

```markdown
## Post-upgrade Verification

- [ ] All nodes upgraded
- [ ] Pods redistributed successfully
- [ ] Helm releases reconciled
- [ ] Applications functional
- [ ] Monitoring working
- [ ] No degraded services
```

## Environment-Specific Sections

### Full Split

```markdown
## CFT Environments

[CFT-specific instructions]

```command
# CFT-specific command
```

Repository: `hmcts/cnp-flux-config`

Example PR: [Update component](https://github.com/hmcts/cnp-flux-config/pull/XXXXX)

## SDS Environments

[SDS-specific instructions]

```command
# SDS-specific command
```

Repository: `hmcts/sds-flux-config`

Example PR: [Update component](https://github.com/hmcts/sds-flux-config/pull/XXXXX)
```

### Compact Mention

```markdown
This procedure applies to both CFT and SDS environments. Use the appropriate flux config repo:
- CFT: `hmcts/cnp-flux-config`
- SDS: `hmcts/sds-flux-config`
```

## Rollback Procedures

### Helm Rollback

```markdown
## Rollback Procedure

If issues occur, rollback the helm release:

```command
# View history
helm history {release-name} -n {namespace}

# Rollback to previous
helm rollback {release-name} -n {namespace}

# Rollback to specific version
helm rollback {release-name} {revision} -n {namespace}
```

Alternative: Revert the flux PR and wait for reconciliation.
```

### Terraform Rollback

```markdown
## Rollback

Revert the Terraform PR and re-run the pipeline:

1. Revert PR in GitHub
2. Run [CFT pipeline](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=766)
3. Monitor deployment
4. Verify resources restored
```

## Known Issues Section

### Format

```markdown
## Known Issues

### Issue: [Descriptive Title]

**Symptoms**:
- Observable behavior
- Error messages

**Cause**: Root cause explanation

**Resolution**:
1. Step 1
2. Step 2

**Prevention**: How to avoid in future

### Issue: [Another Issue]

[Description and resolution]
```

## Related Documentation Links

### Standard Format

```markdown
## Related Documentation

- [Related runbook title](../path/to/runbook.html)
- [Another guide](guide-name.html)
- [Section index](index.html)

## External Resources

- [Official documentation](https://external-link.com)
- [GitHub repository](https://github.com/org/repo)
```

## Notification Templates

### Slack Notification

```markdown
## Notify Teams

Post in #cloud-native-announce (do not use @here):

> 📢 Upcoming maintenance: [Component] upgrade in [Environment] on [Date]
> Expected duration: [Time]
> Impact: [Description]
> Runbook: [Link]

For SDS: Use #sds-cloud-native
```

### Jenkins Downtime Notice

```markdown
Post in #cloud-native-announce:

> ⚠️ Jenkins will be briefly unavailable during PTL/AAT cluster upgrade
> Time: [Time]
> Affected: CFT Jenkins (https://build.hmcts.net/)
> Alternative: Platform Jenkins (https://build.platform.hmcts.net/)
```

## Command Block Formatting

### Simple Command

```markdown
Check current context:

```command
kubectl config current-context
```
```

### Multi-line Command

```markdown
Save pod and HR statuses:

```command
kubectl get pods -A | wc -l > pods_total_count && \
  kubectl get pods -A > pods_all_status && \
  kubectl get hr -A > hr_all_status
```
```

### With Explanation

```markdown
Monitor the deployment (this may take several minutes):

```command
kubectl get hr -n monitoring prometheus-operator -w
```

Press Ctrl+C to stop watching.
```

## Port Forward Examples

```markdown
Port forward to access UI locally:

```command
kubectl port-forward -n {namespace} svc/{service-name} 8080:80
```

Then visit http://localhost:8080 in your browser.
```

## Image References

```markdown
![Screenshot description](images/screenshot-name.png)

![Diagram showing architecture](Images/architecture-diagram.png)
```

## Troubleshooting Steps Format

```markdown
### Step 1: Check [Component]

Describe what to check and why.

```command
relevant command here
```

Expected output: [describe normal output]
If you see [error], this indicates [problem].

### Step 2: Verify [Configuration]

[Instructions]
```

## Production-Specific Notices

### Change Request Template

```markdown
<%= warning_text('A Change Request must be raised 2-3 days before this Production change') %>

Use the [Update AKS Version template](https://mojcppprod.service-now.com/navpage.do) in Service Now.
```

### Cluster-Specific Warning

```markdown
<%= warning_text('For Perftest upgrades, coordinate with the perftest-cluster team beforehand') %>
```

## Useful Aliases Section

```markdown
## Useful Aliases

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgn='kubectl get nodes'
alias kl='kubectl logs'
alias kx='kubectl exec -it'
````
```
