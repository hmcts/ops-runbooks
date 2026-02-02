# Agent Skills

This repository includes [Agent Skills](https://agentskills.io/) to help create and maintain runbooks efficiently.

## Available Skills

- **[runbook-scaffolder](skills/runbook-scaffolder/SKILL.md)** - Creates properly structured runbook files with HMCTS conventions

See [skills/README.md](skills/README.md) for complete documentation.

## Quick Start

Compatible AI agents (GitHub Copilot, Claude Code, Cursor, etc.) will automatically discover and use these skills.

Example:
```
create a runbook for upgrading Traefik in AKS clusters
```

The `runbook-scaffolder` skill will generate a properly formatted file with:
- Correct `.html.md.erb` extension
- Valid YAML frontmatter
- Standard sections (Prerequisites, Procedure, Verification, etc.)
- HMCTS-specific patterns (cluster names, environments, PR examples)
- Appropriate directory placement
