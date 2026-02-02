# GitHub Copilot Agents and Skills

This directory contains agents and skills that extend GitHub Copilot with specialized knowledge for HMCTS operational runbooks.

## Architecture

```
.github/
├── agents/
│   └── runbook-creator-agent.md      # Agent that uses skills
└── skills/
    └── runbook-scaffolder/
        └── SKILL.md                   # Skill with templates and patterns
```

- **Agents** - High-level personas that interact with users and use skills
- **Skills** - Specialized capabilities with templates, patterns, and domain knowledge

## Available Agents

### Runbook Creator Agent
**File**: `agents/runbook-creator-agent.md`

**Purpose**: Creates operational runbooks following HMCTS conventions and contribution guidelines

**What it does**:
- Asks clarifying questions about your documentation needs
- Reads contribution guides from `source/Contribution-Guide/`
- Uses the **runbook-scaffolder** skill for implementation
- Generates `.html.md.erb` files with proper structure
- Provides testing and customization instructions

**Triggers**: "create runbook", "new runbook", "generate guide", "add page", "create documentation"

**Key Features**:
- ✅ Reads contribution guides before creating
- ✅ Uses official templates (how-to, troubleshooting, maintenance)
- ✅ Ensures `.html.md.erb` extension (not `.md`)
- ✅ Follows weight increment rules
- ✅ Includes HMCTS patterns (clusters, repos, environments)
- ✅ Adds PR example placeholders
- ✅ Provides testing instructions

## Available Skills

### Runbook Scaffolder
**File**: `skills/runbook-scaffolder/SKILL.md`

**Purpose**: Provides templates, patterns, and conventions for runbook creation

**Contains**:
- File naming conventions
- YAML frontmatter templates
- HMCTS-specific patterns (cluster names, environments)
- kubectl queries and helm operations
- PR example formats
- Verification checklists
- Rollback procedures
- Command formatting examples

**Used by**: Runbook Creator Agent

**References**:
- `references/PATTERNS.md` - Common patterns and templates
- `references/EXAMPLES.md` - Complete runbook examples

## How It Works

1. **You invoke the agent**: "create a runbook for troubleshooting AppGateway 502 errors"

2. **Agent clarifies**: Asks about type, environments, production impact

3. **Agent reads guides**: 
   - `source/Contribution-Guide/addingpages.html.md.erb`
   - `source/Contribution-Guide/guide-examples/troubleshooting-guide.html.md.erb`

4. **Agent uses skill**: Activates runbook-scaffolder for patterns and templates

5. **Agent creates file**: 
   - `source/network/troubleshooting-appgw-502.html.md.erb`
   - Proper YAML frontmatter
   - Template-based structure
   - HMCTS-specific content

6. **Agent provides instructions**: How to test, what to customize next

## Usage Examples

### Create How-To Guide
```
@runbook-creator create a guide for rotating SSL certificates in Application Gateway
```

Agent will:
- Read how-to template from contribution guides
- Create in `source/Certificates/` or `source/network/`
- Include prerequisites, steps, verification
- Add change request notice if production
- Provide testing instructions

### Create Troubleshooting Guide
```
@runbook-creator generate troubleshooting guide for Prometheus alerts not firing
```

Agent will:
- Read troubleshooting template
- Create in `source/monitoring/`
- Include symptoms, diagnostic steps, resolutions
- Add escalation procedure
- Reference related monitoring docs

### Create Maintenance/Upgrade Guide
```
@runbook-creator document the process for upgrading Dynatrace agents
```

Agent will:
- Read maintenance template
- Create in `source/monitoring/`
- Include environment order, pre-checks
- Add CFT/SDS specific sections
- Include rollback procedure
- Add change request notice

## Contribution Guide Integration

The agent **always** reads and follows:

1. **Main Guide**: `source/Contribution-Guide/index.html.md.erb`
   - Understand documentation benefits and best practices

2. **Adding Pages**: `source/Contribution-Guide/addingpages.html.md.erb`
   - File extension rules (`.html.md.erb`)
   - Weight parameter usage
   - YAML frontmatter requirements
   - Core sections structure

3. **Templates**: `source/Contribution-Guide/guide-examples/`
   - `how-to-guide.html.md.erb` - Operational procedures
   - `troubleshooting-guide.html.md.erb` - Diagnostic guides
   - `maintenance-guide.html.md.erb` - Maintenance tasks

4. **Testing**: `source/Contribution-Guide/testing.html.md.erb`
   - How to preview changes locally

## Critical Rules

### File Extension
**MUST** be `.html.md.erb` - not `.md` or `.md.erb`

### YAML Frontmatter Structure
```yaml
---
title: Action-Oriented Descriptive Title
last_reviewed_on: 2026-02-02
review_in: 12 months
weight: [increment by 10]
---
```

### Content Structure
```erb
# <%= current_page.data.title %>

[Brief description]

## Prerequisites
...
```

### Weight Management
- Increment by 10 from existing files
- Lower numbers appear first
- Agent checks existing files automatically

## HMCTS-Specific Knowledge

Both agent and skill understand:

**Cluster Names**:
- CFT: `cft-{env}-{number}-aks`, `prod-{number}-aks`
- SDS: `ss-{env}-{number}-aks`

**Environments**: Sbox → Ptlsbox → ITHC → Preview → Demo → Perftest → AAT → Production → PTL

**Repositories**:
- CFT: `cnp-flux-config`, `aks-cft-deploy`, `azure-platform-terraform`
- SDS: `sds-flux-config`, `aks-sds-deploy`, `sds-azure-platform`

**Jenkins**:
- CFT: https://build.hmcts.net/
- SDS: https://sds-build.hmcts.net/

## Quality Checklist

Agent verifies before creating:
- [ ] Contribution guides read
- [ ] Appropriate template selected
- [ ] Extension is `.html.md.erb`
- [ ] YAML frontmatter complete
- [ ] Current date used
- [ ] Weight incremented properly
- [ ] Prerequisites included
- [ ] Commands properly formatted
- [ ] PR examples included
- [ ] Environment sections clear
- [ ] Verification steps present

## Testing Your Runbook

After creation:
```bash
bundle exec middleman server
# Visit http://localhost:4567
```

Navigate to your section → your new runbook

## Next Steps After Creation

1. **Add specifics**: Replace placeholder cluster names and IPs
2. **Update PRs**: Add real PR links from hmcts repos
3. **Test commands**: Verify all commands in sandbox environment
4. **Add screenshots**: Place in `images/` subdirectory
5. **Cross-reference**: Link to related runbooks

## Benefits

- **Consistency**: All runbooks follow the same structure
- **Compliance**: Automatically follows contribution guidelines
- **HMCTS-Aware**: Knows cluster names, repos, environments
- **Template-Based**: Uses official templates from contribution guide
- **Quality**: Built-in checks prevent common mistakes
- **Efficient**: Creates complete runbooks in seconds

## Support

If the agent doesn't work as expected:
1. Check your prompt is specific
2. Provide context (type, environments)
3. Review contribution guides
4. Check `.github/copilot-instructions.md`

## Related Documentation

- [Main README](../../README.md)
- [Contribution Guide](../../source/Contribution-Guide/index.html.md.erb)
- [GitHub Copilot Instructions](../copilot-instructions.md)
