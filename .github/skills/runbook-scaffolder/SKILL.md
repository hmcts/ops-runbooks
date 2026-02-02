---
name: Runbook Creator
description: Creates operational runbooks and documentation for HMCTS platform team following Middleman conventions. Generates .html.md.erb files with proper YAML frontmatter, standard sections, and HMCTS-specific patterns (cluster names, environments, PR examples). Uses contribution guides and templates. Triggers on "create runbook", "new runbook", "generate guide", "create documentation", "add page", "new operational doc".
tools: ['read', 'edit', 'create_file', 'list_dir', 'grep_search', 'semantic_search', 'replace_string_in_file', 'multi_replace_string_in_file']
---

# Runbook Creator

Creates properly structured operational runbooks for the HMCTS Platform Operations team following repository conventions and contribution guidelines.

## When to Use This Skill

Use this skill when you need to:
- Create new operational runbooks or how-to guides
- Generate troubleshooting documentation
- Document upgrade, patching, or maintenance procedures
- Create quick reference guides
- Set up index pages for new documentation sections

## Critical: Read Contribution Guides First

**ALWAYS** read the following files before creating any documentation:

1. **Main Guide**: `source/Contribution-Guide/index.html.md.erb`
   - Understand the benefits and best practices
   
2. **Adding Pages**: `source/Contribution-Guide/addingpages.html.md.erb`
   - File naming conventions (`.html.md.erb` extension)
   - YAML frontmatter requirements
   - Weight parameter usage
   - Core sections structure

3. **Guide Templates**: `source/Contribution-Guide/guide-examples/`
   - `how-to-guide.html.md.erb` - For operational procedures
   - `troubleshooting-guide.html.md.erb` - For diagnostic guides
   - `maintenance-guide.html.md.erb` - For routine maintenance tasks

4. **Testing Guide**: `source/Contribution-Guide/testing.html.md.erb`
   - How to preview changes locally

## File Conventions

### Extension (CRITICAL)
**MUST** use `.html.md.erb` extension - NOT `.md`

Common mistake:
- ❌ `filename.md.erb`
- ✅ `filename.html.md.erb`

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
last_reviewed_on: 2026-02-02
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

## Step-by-Step Creation Process

### Step 1: Clarify Requirements
Ask the user:
- What is the runbook topic?
- What type? (how-to, troubleshooting, maintenance, reference)
- Which environments? (CFT, SDS, or both)
- Is this a production procedure? (needs Change Request notice)

### Step 2: Read Contribution Guides
Use `read` tool to load:
- `source/Contribution-Guide/addingpages.html.md.erb`
- Appropriate template from `source/Contribution-Guide/guide-examples/`

### Step 3: Determine Location
- Identify appropriate directory in `source/`
- Use `list_dir` to check existing files
- Identify next weight value (increment by 10)

### Step 4: Select Template

**For How-To/Operational Procedures**:
Use template from `source/Contribution-Guide/guide-examples/how-to-guide.html.md.erb`:
```markdown
## How to [Perform Specific Task]
Brief description

## Prerequisites
- Access level required
- Necessary tools
- Required knowledge

## How-to steps
1. First step (include screenshots and example commands/PRs)
2. Second step
3. Third step

## Verification
How to verify success
- Third-party team involvement?

## Troubleshooting
Common issues and resolutions

## Additional Information
- Related tasks
- Links to documentation
- Best practices
```

**For Troubleshooting Guides**:
Use template from `source/Contribution-Guide/guide-examples/troubleshooting-guide.html.md.erb`:
```markdown
## Troubleshooting [System/Application]
Diagnostic and resolution steps

## Prerequisites
- Log access
- Administrative access
- Understanding of technologies

## Common Issues and Solutions

### Issue 1: [Description]
1. Diagnostic step
2. Resolution step
3. Verification step

### Issue 2: [Description]
...

## Escalation Procedure
Steps if unresolved

## Additional Information
- Documentation links
- Contact information
```

**For Maintenance/Upgrade Procedures**:
Use template from `source/Contribution-Guide/guide-examples/maintenance-guide.html.md.erb`:
```markdown
## [System] Maintenance Guide
Routine maintenance tasks

## Prerequisites
- Administrative access
- Maintenance window
- Backup of current state
- Change process required?

## Maintenance Tasks

### Task 1: [Description]
Frequency: [Schedule]
1. Step one
2. Step two

### Task 2: [Description]
...

## Verification
Success criteria
- Third-party verification needed?

## Rollback Procedure
Revert steps if issues arise

## Additional Information
- Maintenance schedule
- System availability impact
- Support contacts
```

### Step 5: Add HMCTS-Specific Context

**Cluster Names**:
- CFT Format: `cft-{env}-{number}-aks` or `prod-{number}-aks`
- SDS Format: `ss-{env}-{number}-aks`

**Environment Order**:
1. Sbox (cft-sbox-00-aks, cft-sbox-01-aks / ss-sbox-00-aks, ss-sbox-01-aks)
2. Ptlsbox (cft-ptlsbox-00-aks / ss-ptlsbox-00-aks)
3. ITHC (cft-ithc-00-aks, cft-ithc-01-aks / ss-ithc-00-aks, ss-ithc-01-aks)
4. Preview (cft-preview-00-aks / ss-dev-01-aks)
5. Demo (cft-demo-00-aks, cft-demo-01-aks / ss-demo-00-aks, ss-demo-01-aks)
6. Perftest (cft-perftest-00-aks, cft-perftest-01-aks / ss-test-00-aks, ss-test-01-aks)
7. AAT (cft-aat-00-aks, cft-aat-01-aks / ss-stg-00-aks, ss-stg-01-aks)
8. Production (prod-00-aks, prod-01-aks / ss-prod-00-aks, ss-prod-01-aks)
9. PTL (cft-ptl-00-aks / ss-ptl-00-aks)

**Repositories**:
- CFT Flux: `hmcts/cnp-flux-config`
- CFT AKS: `hmcts/aks-cft-deploy`
- CFT Azure: `hmcts/azure-platform-terraform`
- SDS Flux: `hmcts/sds-flux-config`
- SDS AKS: `hmcts/aks-sds-deploy`
- SDS Azure: `hmcts/sds-azure-platform`
- Jenkins: `hmcts/cnp-jenkins-config`

**Jenkins URLs**:
- CFT: https://build.hmcts.net/
- SDS: https://sds-build.hmcts.net/
- Platform: https://build.platform.hmcts.net/

**PR Examples Format**:
```markdown
Example PRs:
- [CFT example](https://github.com/hmcts/cnp-flux-config/pull/XXXXX)
- [SDS example](https://github.com/hmcts/sds-flux-config/pull/XXXXX)
```

**Change Request Notice** (for Production):
```erb
<%= warning_text('A Change Request must be raised 2-3 days before performing this in Production via <a href="https://mojcppprod.service-now.com/navpage.do">Service Now</a>') %>
```

**Command Formatting**:
````markdown
```command
kubectl get pods -A
```
````

**Images**:
Store in `images/` or `Images/` subdirectory:
```markdown
![Description](images/screenshot.png)
```

### Step 6: Create the File

Use `create_file` tool with:
- Correct path: `source/[directory]/[filename].html.md.erb`
- YAML frontmatter with current date (2026-02-02)
- Template-based content structure
- HMCTS-specific patterns
- Appropriate weight value

### Step 7: Provide Testing Instructions

Tell the user:
```
✅ Runbook created: source/[directory]/[filename].html.md.erb

📚 Based on template: source/Contribution-Guide/guide-examples/[template].html.md.erb

🔧 Test locally:
1. bundle exec middleman server
2. Visit http://localhost:4567
3. Navigate to [section] → [title]

📝 Next steps:
- Add specific cluster names/IPs
- Update PR example links with real PRs
- Test all commands
- Add screenshots to images/ directory
```

## Quality Checklist

Before creating, verify:
- [ ] Read contribution guide (`source/Contribution-Guide/addingpages.html.md.erb`)
- [ ] Read appropriate template from `guide-examples/`
- [ ] Extension is `.html.md.erb` (NOT `.md.erb`)
- [ ] YAML frontmatter complete with current date
- [ ] Title is descriptive and action-oriented
- [ ] Weight appropriate (increment by 10)
- [ ] Prerequisites section included
- [ ] Commands use proper formatting (backticks or code blocks)
- [ ] PR examples use hmcts repos
- [ ] Environment-specific sections clear (CFT/SDS)
- [ ] Verification steps included
- [ ] Troubleshooting/Known issues section
- [ ] Related documentation linked
- [ ] Images reference correct subdirectory
- [ ] Internal links use relative paths

## Common Patterns

### Environment-Specific Sections
When CFT and SDS differ:
```markdown
## CFT Environments
[CFT-specific steps]
- [CFT example](https://github.com/hmcts/cnp-flux-config/pull/XXXXX)

## SDS Environments
[SDS-specific steps]
- [SDS example](https://github.com/hmcts/sds-flux-config/pull/XXXXX)
```

### Pre-flight Checks
```markdown
## Pre-upgrade Health Checks

```command
kubectl config current-context
kubectl get pods -A | wc -l
kubectl get pods -A | awk '!/(Running|Succeeded|Completed)/'
kubectl get hr -A | awk '/(Unknown|False)/'
```
```

### Verification Checklist
```markdown
## Verification
- [ ] Component running
- [ ] No CrashLoopBackOff
- [ ] Functionality working
- [ ] No alerts firing
```

## Anti-Patterns (AVOID)

- ❌ Using `.md` or `.md.erb` extension (must be `.html.md.erb`)
- ❌ Skipping YAML frontmatter
- ❌ Not reading contribution guides first
- ❌ Forgetting to set `last_reviewed_on` date
- ❌ Using absolute URLs for internal links
- ❌ Missing verification steps
- ❌ Not updating both CFT and SDS when applicable

## Reference Files to Read

Always check these before creating documentation:
- `source/Contribution-Guide/index.html.md.erb` - Main guide
- `source/Contribution-Guide/addingpages.html.md.erb` - Page creation rules
- `source/Contribution-Guide/guide-examples/how-to-guide.html.md.erb` - How-to template
- `source/Contribution-Guide/guide-examples/troubleshooting-guide.html.md.erb` - Troubleshooting template
- `source/Contribution-Guide/guide-examples/maintenance-guide.html.md.erb` - Maintenance template
- `source/Contribution-Guide/testing.html.md.erb` - Testing instructions
- `source/Contribution-Guide/troubleshooting.html.md.erb` - Common file issues
