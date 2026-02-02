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

**Complete Directory Structure**:
- `source/Access-and-Permissions/` - Access control, RBAC, conditional access policies
- `source/acr/` - Azure Container Registry operations and synchronization
- `source/aks/` - AKS cluster operations, upgrades, patching, maintenance
- `source/AppAttach/` - App attach scripts and VM configuration
- `source/azure-pipelines/` - Azure DevOps pipeline issues and troubleshooting
- `source/BAIS/` - BAIS-specific documentation
- `source/BAU-Live-Services/` - Business as usual and live service operations
- `source/Camunda/` - Camunda-specific procedures
- `source/Certificates/` - Certificate management and renewal procedures
- `source/Change-Requests/` - Change request procedures and templates
- `source/Contribution-Guide/` - Documentation contribution guides and templates
- `source/Crime/` - Crime service documentation
- `source/database/` - Database operations, maintenance, and troubleshooting
- `source/DLRM/` - DLRM-specific documentation
- `source/Domain-Services/` - Domain services procedures
- `source/Elastic-Search-and-Logstash/` - Elasticsearch and Logstash operations
- `source/FinOps/` - Financial operations and cost management
- `source/FSLogix-Application-Masking/` - FSLogix configuration
- `source/heritage/` - Legacy system documentation
- `source/Java-Upgrade/` - Java upgrade procedures
- `source/jenkins/` - Jenkins operations and troubleshooting
- `source/monitoring/` - Monitoring, alerts, observability, and Dynatrace
- `source/network/` - Networking, VPN, DNS, connectivity, and AppGateway
- `source/neuvector/` - NeuVector security operations
- `source/onboarding/` - Onboarding procedures and guides
- `source/oncall/` - On-call procedures and incident response
- `source/Patching/` - Patching procedures and schedules
- `source/PlatOps-Toolkit/` - Platform operations toolkit
- `source/SAS-Token/` - SAS token management
- `source/Security/` - Security procedures and policies
- `source/Services/` - Service-specific documentation
- `source/Terraform/` - Infrastructure as Code and Terraform operations
- `source/Testing-Changes/` - Testing procedures and validation
- `source/vendor-support/` - Vendor support procedures

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

Apply HMCTS-specific patterns as defined in `.github/copilot-instructions.md`:
- Cluster naming conventions (CFT: `cft-*-aks`, SDS: `ss-*-aks`)
- Environment progression order
- Repository references (cnp-flux-config, sds-flux-config, etc.)
- Jenkins URLs
- PR example formats
- Change Request notices for production procedures
- Command formatting with backticks or code blocks
- Image references in subdirectories

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
Runbook created: source/[directory]/[filename].html.md.erb
Based on: source/Contribution-Guide/guide-examples/[template].html.md.erb

Test locally:
  bundle exec middleman server
  Visit http://localhost:4567

Next steps:
- Add specific cluster names/IPs
- Update PR links
- Test commands
- Add screenshots to images/
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
kubectl config current-context
kubectl get pods -A | wc -l
kubectl get pods -A | awk '!/(Running|Succeeded|Completed)/'
kubectl get hr -A | awk '/(Unknown|False)/'
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
