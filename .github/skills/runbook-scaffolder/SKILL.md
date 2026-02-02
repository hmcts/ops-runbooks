---
name: runbook-scaffolder
description: Creates operational runbooks for HMCTS platform team following Middleman conventions. Generates .html.md.erb files with proper YAML frontmatter, standard sections, and HMCTS-specific patterns (cluster names, environments, PR examples). Use when creating how-to guides, troubleshooting docs, upgrade procedures, patching guides, or reference documentation. Triggers on "create runbook", "new runbook", "generate guide", "scaffolding runbook".
---

# Runbook Scaffolder

Creates properly structured operational runbooks for the HMCTS Platform Operations team following repository conventions.

## When to Use This Skill

Use this skill when you need to:
- Create new operational runbooks or how-to guides
- Generate troubleshooting documentation
- Document upgrade or patching procedures
- Create quick reference guides
- Set up index pages for new sections

## Quick Start

1. Specify the runbook topic and type
2. Skill generates appropriate file with correct structure
3. Customize with specific details (cluster names, PR links)
4. Preview locally: `bundle exec middleman server`

## File Conventions

### Extension
All runbook files use `.html.md.erb` extension (never `.md`)

### Location
Files go in `source/` directory under appropriate subdirectory:
- `source/aks/` - AKS operations, upgrades, patching
- `source/azure-pipelines/` - Azure DevOps issues
- `source/jenkins/` - Jenkins operations
- `source/monitoring/` - Monitoring, alerts, Dynatrace
- `source/network/` - Network, VPN, DNS, AppGateway
- `source/Terraform/` - IaC operations
- `source/Security/` - Security procedures
- `source/database/` - Database operations
- `source/Certificates/` - Certificate management
- `source/oncall/` - On-call, incident response

### Required YAML Frontmatter

```yaml
---
title: Descriptive Action-Oriented Title
last_reviewed_on: YYYY-MM-DD
review_in: 12 months
weight: [increment by 10 from existing files]
---
```

### Content Structure

```erb
# <%= current_page.data.title %>

[Brief description]

## Prerequisites
...
```

## Runbook Types and Templates

### Troubleshooting Guide

```markdown
# <%= current_page.data.title %>

Brief description of the problem this guide solves.

## Prerequisites
- Required access/tools
- Required knowledge

## Symptoms
- Observable issues
- When this occurs

## Diagnostic Steps

### Step 1: Check [Component]
```command
kubectl get pods -A
```

### Step 2: Verify [Configuration]
...

## Common Resolutions

### Resolution 1: [Fix Description]
[Instructions]

**Example PRs**:
- [CFT example](https://github.com/hmcts/cnp-flux-config/pull/XXXXX)
- [SDS example](https://github.com/hmcts/sds-flux-config/pull/XXXXX)

## Verification
- [ ] Issue resolved
- [ ] No errors in logs
- [ ] Systems functional

## Prevention
[How to avoid this issue]

## Known Issues

### Issue: [Description]
**Cause**: [Root cause]
**Resolution**: [Fix]

## Related Documentation
- [Link to related runbook](../path/to/related.html)
```

### Upgrade/Patching Procedure

```markdown
# <%= current_page.data.title %>

Description of what is being upgraded.

## Prerequisites
- Cluster access
- GitHub repo access
- Understanding of component

## When to Use This Guide
Use when upgrading [component] across environments.

## Planning

Check release notes: [link]
Review renovate PRs:
- [CFT](https://github.com/hmcts/cnp-flux-config/pulls)
- [SDS](https://github.com/hmcts/sds-flux-config/pulls)

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

<%= warning_text('A Change Request must be raised 2-3 days before Production upgrades') %>

## Pre-upgrade Health Checks

```command
kubectl config current-context
kubectl get pods -A | wc -l
kubectl get hr -A | awk '/(Unknown|False)/'
```

## Procedure

### Step 1: Update Configuration

#### CFT Environments
- [Example PR](https://github.com/hmcts/cnp-flux-config/pull/XXXXX)

#### SDS Environments
- [Example PR](https://github.com/hmcts/sds-flux-config/pull/XXXXX)

### Step 2: Monitor Deployment

```command
kubectl get hr -n [namespace] [release-name] -w
```

## Verification
- [ ] Component running
- [ ] No CrashLoopBackOff
- [ ] Functionality working
- [ ] No alerts firing

## Rollback Procedure

```command
helm history [release] -n [namespace]
helm rollback [release] [revision] -n [namespace]
```

## Known Issues

### Issue: [Common Problem]
[Description and resolution]

## Related Documentation
- [Related guide](../path/to/guide.html)
```

### Quick Reference

```markdown
# <%= current_page.data.title %>

Quick reference for [tool/topic].

## Prerequisites
- Tool installed
- Appropriate access

## Common Commands

### [Category]

```command
# Description
command here
```

### [Another Category]

```command
# Description
another command
```

## Useful Aliases

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
```

## Tips and Tricks

- Tip 1
- Tip 2

## Related Documentation
- [Link](../path.html)
```

### Index Page

```erb
---
title: Section Title
weight: [number]
---

# <%= current_page.data.title %>

Brief description of this section and what runbooks it contains.

## Contents

- Topic area 1
- Topic area 2
- Topic area 3

## Related Sections

- [Other section](../other/index.html)
```

## HMCTS-Specific Patterns

### Cluster Names

**CFT Format**: `cft-{env}-{number}-aks` or `prod-{number}-aks`
Examples: `cft-sbox-00-aks`, `prod-01-aks`

**SDS Format**: `ss-{env}-{number}-aks`
Examples: `ss-sbox-00-aks`, `ss-prod-01-aks`

### Repositories

**CFT**:
- Flux: `hmcts/cnp-flux-config`
- AKS: `hmcts/aks-cft-deploy`
- Azure: `hmcts/azure-platform-terraform`
- Jenkins: `hmcts/cnp-jenkins-config`

**SDS**:
- Flux: `hmcts/sds-flux-config`
- AKS: `hmcts/aks-sds-deploy`
- Azure: `hmcts/sds-azure-platform`

### Jenkins URLs
- CFT: https://build.hmcts.net/
- SDS: https://sds-build.hmcts.net/
- Platform: https://build.platform.hmcts.net/

### Environment-Specific Sections

When procedures differ between CFT and SDS:

```markdown
## CFT Environments

[CFT-specific steps]

- [CFT example PR](https://github.com/hmcts/cnp-flux-config/pull/XXXXX)

## SDS Environments

[SDS-specific steps]

- [SDS example PR](https://github.com/hmcts/sds-flux-config/pull/XXXXX)
```

### Change Request Notices

For production changes:

```erb
<%= warning_text('A Change Request must be raised 2-3 days before performing this in Production via <a href="https://mojcppprod.service-now.com/navpage.do">Service Now</a>') %>
```

### Command Formatting

Inline commands: \`kubectl get pods\`

Command blocks:
````
```command
kubectl get pods -A | awk '!/(Running|Succeeded|Completed)/'
```
````

### Images

Store in `images/` or `Images/` subdirectory:
```markdown
![Alt text](images/screenshot.png)
```

## Weight Management

- Check existing files: `ls -l source/[directory]/`
- Increment by 10: 10, 20, 30, 40...
- Lower numbers appear first in navigation
- Index pages typically use weight 1-10

## Creation Workflow

1. **Clarify Requirements**
   - What's the runbook topic?
   - What type? (troubleshooting, upgrade, reference)
   - Which environments? (CFT, SDS, both)
   - Production procedure? (needs CR notice)

2. **Determine Location**
   - Select appropriate `source/` subdirectory
   - Check existing files for weight values

3. **Generate Structure**
   - Create `.html.md.erb` file
   - Add YAML frontmatter with current date
   - Include appropriate template sections
   - Set weight higher than existing files

4. **Add HMCTS Context**
   - Use correct cluster naming
   - Include repo-specific PR examples
   - Add environment progression if applicable
   - Include CR notice if production-impacting

5. **Quality Check**
   - Extension is `.html.md.erb`
   - YAML frontmatter complete
   - Title is action-oriented
   - Commands use proper formatting
   - Internal links use relative paths
   - Weight is appropriate

## Output Format

After creating a runbook, provide:

```
✅ Runbook created successfully!

📁 Location: source/[directory]/[filename].html.md.erb
📋 Type: [Troubleshooting/Upgrade/Reference/etc]
⚖️  Weight: [number]
📅 Review date: [date] (12 months)

🔧 How to test:
1. bundle exec middleman server
2. Visit http://localhost:4567
3. Navigate to [section] → [title]

💡 Next steps:
- Add specific cluster names/IPs
- Update PR example links
- Test all commands
- Add screenshots to images/ directory
```

## Quality Checklist

Before finalizing:
- [ ] Extension is `.html.md.erb`
- [ ] YAML frontmatter complete and valid
- [ ] Title is descriptive and action-oriented
- [ ] Current date in `last_reviewed_on`
- [ ] Weight appropriate for section
- [ ] Prerequisites section included
- [ ] Commands properly formatted
- [ ] PR examples use hmcts repos
- [ ] Environment-specific sections clear
- [ ] Verification steps included
- [ ] Known issues section present
- [ ] Related documentation linked
- [ ] Images in images/ subdirectory
- [ ] Internal links use relative paths

## Examples

See `references/EXAMPLES.md` for complete examples of:
- Troubleshooting guides
- Upgrade procedures
- Quick references
- Index pages

## Common Patterns Reference

See `references/PATTERNS.md` for:
- Environment lists
- Pre-flight checks
- Common kubectl queries
- Helm operations
- PR example formats
