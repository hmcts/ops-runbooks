# GitHub Copilot Agent and Skills

This directory contains the **Runbook Creator Agent** and supporting skills for creating HMCTS operational documentation.

## Architecture

```
.github/
├── agents/
│   ├── README.md
│   └── runbook-creator-agent.md       # User-facing agent
└── skills/
    ├── README.md
    └── runbook-scaffolder/
        └── SKILL.md                    # Templates and patterns
```

- **Agent** - User-facing persona that asks questions, reads contribution guides, and creates documentation
- **Skills** - Provides templates, patterns, and domain-specific knowledge

## Quick Start

### Using the Agent

```
@runbook-creator create a troubleshooting guide for Application Gateway 502 errors
```

The agent will:
1. Ask clarifying questions (environments, production impact)
2. Read contribution guides from `source/Contribution-Guide/`
3. Use runbook-scaffolder skill for templates and patterns
4. Create properly formatted `.html.md.erb` file
5. Provide testing and customization instructions

### What Gets Created

- ✅ Correct file extension: `.html.md.erb` (not `.md`)
- ✅ Valid YAML frontmatter with current date
- ✅ Template-based structure from contribution guides
- ✅ HMCTS-specific patterns (clusters, repos, PRs)
- ✅ Verification and rollback procedures
- ✅ Testing instructions

## Documentation

- **[agents/README.md](agents/README.md)** - Complete agent documentation
- **[skills/README.md](skills/README.md)** - Skills documentation
- **[copilot-instructions.md](copilot-instructions.md)** - Workspace context for Copilot

## Features

### Contribution Guide Integration
Agent reads and follows:
- `source/Contribution-Guide/addingpages.html.md.erb` - File rules
- `source/Contribution-Guide/guide-examples/` - Official templates
  - how-to-guide.html.md.erb
  - troubleshooting-guide.html.md.erb
  - maintenance-guide.html.md.erb

### HMCTS-Specific Knowledge
- Cluster naming (cft-*, ss-*, prod-*)
- Environment order (Sbox → PTL)
- Repository references (cnp-flux-config, sds-flux-config)
- Jenkins URLs
- PR example formats
- Change Request notices

### Quality Checks
- Correct file extension enforcement
- Weight increment rules
- YAML frontmatter validation
- Template-based structure
- Verification steps inclusion

## Examples

**Create how-to guide:**
```
@runbook-creator document how to rotate SSL certificates
```

**Create troubleshooting guide:**
```
@runbook-creator troubleshooting guide for Prometheus alerts not firing
```

**Create maintenance guide:**
```
@runbook-creator document upgrading Dynatrace agents across environments
```

See [agents/README.md](agents/README.md) for more examples and complete documentation.
