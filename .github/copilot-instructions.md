# GitHub Copilot Instructions for ops-runbooks

This file provides workspace-level context for GitHub Copilot when working in the HMCTS ops-runbooks repository.

## Repository Overview

This is a documentation repository containing operational runbooks and how-to guides for the HMCTS Platform Operations team. The documentation is built using Middleman and hosted on GitHub Pages.

**Site URL**: https://hmcts.github.io/ops-runbooks/

## File Structure Conventions

### Markdown Files
- All runbook pages use `.html.md.erb` extension (not `.md`)
- Files are located in the `source/` directory
- Each major section has its own subdirectory
- First page in each directory must be named `index.html.md.erb`

### YAML Frontmatter (Required)
Every runbook file must start with:
```yaml
---
title: Page Title Here
last_reviewed_on: YYYY-MM-DD
review_in: 12 months
weight: [number]
---
```

### Content Structure
After frontmatter, include:
```erb
# <%= current_page.data.title %>

[Content starts here]
```

## Directory Organization

- `source/aks/` - AKS cluster operations, upgrades, patching
- `source/azure-pipelines/` - Azure DevOps pipeline issues
- `source/jenkins/` - Jenkins operations
- `source/monitoring/` - Monitoring, alerts, observability
- `source/network/` - Networking, VPN, DNS
- `source/Terraform/` - Infrastructure as Code
- `source/Security/` - Security procedures
- `source/database/` - Database operations
- `source/Certificates/` - Certificate management
- `source/oncall/` - On-call and incident response
- `source/Contribution-Guide/` - How to contribute to this repo

## HMCTS-Specific Context

### Environments
Common environments in order of promotion:
1. Sbox (sandbox)
2. Ptlsbox (PTL sandbox)
3. ITHC (integration testing)
4. Preview
5. Demo
6. Perftest (performance testing)
7. AAT (acceptance testing)
8. Production
9. PTL (production-like)

### Cluster Naming Conventions

**CFT Clusters**:
- Format: `cft-{env}-{number}-aks`
- Examples: `cft-sbox-00-aks`, `cft-preview-01-aks`, `prod-00-aks`

**SDS Clusters**:
- Format: `ss-{env}-{number}-aks`
- Examples: `ss-sbox-00-aks`, `ss-prod-01-aks`

### Repository References

**CFT Repositories**:
- Flux Config: `hmcts/cnp-flux-config`
- AKS Deploy: `hmcts/aks-cft-deploy`
- Azure Platform: `hmcts/azure-platform-terraform`

**SDS Repositories**:
- Flux Config: `hmcts/sds-flux-config`
- AKS Deploy: `hmcts/aks-sds-deploy`
- Azure Platform: `hmcts/sds-azure-platform`

**Common**:
- Jenkins Config: `hmcts/cnp-jenkins-config`

### Jenkins Instances
- CFT: https://build.hmcts.net/
- SDS: https://sds-build.hmcts.net/
- Platform: https://build.platform.hmcts.net/

## Writing Style

### Commands
- Use \`backticks\` for inline commands
- Use \`\`\`command blocks for multi-line commands
- Always test commands before documenting

### Links
- Use markdown links: `[text](url)`
- Internal links use relative paths: `[guide](../path/to/guide.html)`
- Include PR examples from actual HMCTS repos

### Warnings and Notices
Use ERB helper macros:
```erb
<%= warning_text('Important warning message here') %>
```

### Images
- Store in `images/` or `Images/` subdirectory within each section
- Reference: `![alt text](images/filename.png)`

## Common Patterns

### Environment-Specific Instructions
When procedures differ between CFT and SDS:
```markdown
## CFT Environments
[CFT-specific steps]

## SDS Environments
[SDS-specific steps]
```

### PR Examples
Always link to real examples:
```markdown
- [CFT example](https://github.com/hmcts/cnp-flux-config/pull/12345)
- [SDS example](https://github.com/hmcts/sds-flux-config/pull/6789)
```

### Change Request Notices
For production changes:
```erb
<%= warning_text('A Change Request must be raised 2-3 days before...') %>
```

### Pre-flight Checks
Common pattern for upgrade/maintenance procedures:
```markdown
## Pre-flight Checks
- Check cluster health: `kubectl get nodes`
- Review pod status: `kubectl get pods -A`
- Check helm releases: `kubectl get hr -A`
```

## Code Quality

### When Generating Runbooks
- Include Prerequisites section
- Add Verification/Testing steps
- Include Known Issues section
- Link to Related Documentation
- Set appropriate weight (increment by 10)
- Use current date for `last_reviewed_on`

### When Editing Runbooks
- Maintain existing formatting
- Update `last_reviewed_on` date if making significant changes
- Preserve YAML frontmatter structure
- Keep environment-specific sections clearly separated

## Testing

### Preview Locally
```bash
bundle exec middleman server
# Visit http://localhost:4567
```

### Build Static Site
```bash
bundle exec middleman build
```

### Check External URLs
```bash
export GH_TOKEN=$(gh auth token)
bundle exec rake check_urls
```

## Common Tasks

### Create New Runbook
1. Choose appropriate directory in `source/`
2. Create file with `.html.md.erb` extension
3. Add required YAML frontmatter
4. Follow standard section structure
5. Set weight higher than existing files in directory
6. Test locally before committing

### Create New Section
1. Create directory under `source/`
2. Create `index.html.md.erb` as first page
3. Set appropriate weight in frontmatter
4. Add section description
5. Create subdirectories as needed (e.g., `images/`)

### Update Existing Content
1. Verify current accuracy
2. Update `last_reviewed_on` date
3. Maintain existing structure
4. Test locally
5. Check related runbooks for consistency

## Tools and Technologies

- **Middleman**: Static site generator
- **Ruby**: Runtime and Bundler for dependencies
- **Markdown/ERB**: Content format
- **Git/GitHub**: Version control and hosting
- **GitHub Pages**: Site hosting

## Agent Skills

This repository uses [Agent Skills](https://agentskills.io/) for extending AI capabilities:

- **runbook-scaffolder**: Generates new runbook files with proper structure
  - See `.agent/skills/runbook-scaffolder/SKILL.md` for details
  - Auto-activates on "create runbook", "new runbook", "generate guide"

## Anti-Patterns to Avoid

- ❌ Don't use `.md` extension (use `.html.md.erb`)
- ❌ Don't skip YAML frontmatter
- ❌ Don't forget to set `last_reviewed_on` date
- ❌ Don't use absolute URLs for internal links
- ❌ Don't include untested commands
- ❌ Don't create runbooks without verification steps
- ❌ Don't forget to update both CFT and SDS variants when applicable

## Quality Checklist

When creating or editing runbooks:
- [ ] YAML frontmatter is complete and valid
- [ ] File has `.html.md.erb` extension
- [ ] Title is descriptive and action-oriented
- [ ] Prerequisites are listed
- [ ] Commands are tested and current
- [ ] PR examples link to real repos
- [ ] Images are in appropriate subdirectory
- [ ] Related documentation is linked
- [ ] Environment-specific sections are clear
- [ ] Known issues are documented
- [ ] Verification/testing steps are included
- [ ] Local preview tested successfully

## Getting Help

- Review existing runbooks in `source/` for examples
- Check `source/Contribution-Guide/` for detailed guidance
- See `README.md` for project setup
- Use GitHub Issues for questions or improvements
