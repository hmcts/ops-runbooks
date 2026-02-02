# Agent Skills for ops-runbooks

This directory contains [Agent Skills](https://agentskills.io/) that extend AI agent capabilities with specialized knowledge for creating and maintaining HMCTS operational runbooks.

## What are Agent Skills?

Agent Skills are a standardized, open format for giving AI agents specialized capabilities. Each skill is a folder containing a `SKILL.md` file with:
- **Metadata** (name, description) - loaded at startup to identify when the skill is relevant
- **Instructions** (Markdown body) - loaded when the skill is activated
- **Resources** (optional) - scripts, references, and assets loaded as needed

This follows **progressive disclosure** to efficiently use context.

## Available Skills

### runbook-scaffolder

**Purpose**: Creates operational runbooks following HMCTS conventions

**Triggers**: "create runbook", "new runbook", "generate guide", "scaffolding runbook"

**Capabilities**:
- Generates `.html.md.erb` files with proper YAML frontmatter
- Creates standard sections based on runbook type
- Includes HMCTS-specific patterns (cluster names, environments, repos)
- Suggests appropriate directory placement
- Sets correct weight values

**Use when**:
- Creating new troubleshooting guides
- Documenting upgrade/patching procedures
- Writing quick reference docs
- Setting up index pages

See [`runbook-scaffolder/SKILL.md`](runbook-scaffolder/SKILL.md) for full documentation.

## How Skills Work

1. **Discovery**: Agent scans `.agent/skills/` at startup
2. **Metadata Loading**: Loads `name` and `description` from each `SKILL.md` frontmatter
3. **Task Matching**: When user request matches description, skill activates
4. **Execution**: Agent loads full `SKILL.md` instructions and follows them
5. **Resources**: Additional files loaded only when referenced

## Using Skills

Skills activate automatically when AI agents detect relevant tasks. Compatible agents include:
- GitHub Copilot
- Claude Code
- Cursor
- Cline
- Windsurf
- And others supporting the Agent Skills format

### Example Usage

```
create a runbook for troubleshooting Jenkins pipeline failures
```

The `runbook-scaffolder` skill will:
1. Auto-activate (matches "create runbook")
2. Ask clarifying questions
3. Generate properly structured file
4. Place in correct directory
5. Include HMCTS-specific patterns

## Skill Structure

```
.agent/skills/
└── runbook-scaffolder/
    ├── SKILL.md              # Required: metadata + instructions
    └── references/           # Optional: documentation
        ├── EXAMPLES.md       # Complete runbook examples
        └── PATTERNS.md       # Reusable patterns
```

## Creating New Skills

To add a new skill:

1. **Create directory**: `.agent/skills/[skill-name]/`
2. **Create SKILL.md** with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: What it does and when to use it. Include triggers.
   ---
   ```
3. **Add instructions** in Markdown below frontmatter
4. **Optional**: Add `scripts/`, `references/`, `assets/` as needed
5. **Test**: Use the skill on real tasks

### Naming Conventions

- **name**: lowercase, hyphens only, 1-64 chars, must match folder name
- **description**: Max 1024 chars, include what it does AND when to use it
- **folder**: Use kebab-case (e.g., `runbook-scaffolder`)

### Best Practices

- Keep `SKILL.md` under 500 lines
- Move detailed content to `references/`
- Include specific trigger phrases in description
- Write instructions for the AI agent, not humans
- Test on real tasks and iterate

## Validation

Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) library to validate:

```bash
pip install agentskills
skills-ref validate .agent/skills/runbook-scaffolder
```

## Future Skills (Planned)

### doc-reviewer
Identifies runbooks past review date, checks links, validates commands

### command-validator
Validates kubectl/az/terraform syntax, checks for deprecated APIs

### pr-finder
Searches for relevant PR examples, updates outdated links

### cross-env-checker
Ensures CFT/SDS consistency, identifies missing variants

## Resources

- [Agent Skills Homepage](https://agentskills.io/)
- [Specification](https://agentskills.io/specification)
- [Integration Guide](https://agentskills.io/integrate-skills)
- [Example Skills](https://github.com/anthropics/skills)
- [Reference Implementation](https://github.com/agentskills/agentskills)

## Contributing

When adding or updating skills:

1. Follow the [Agent Skills specification](https://agentskills.io/specification)
2. Keep descriptions focused and trigger-rich
3. Test with real runbook creation tasks
4. Update this README with new skills
5. Consider validation before committing

## Support

Skills are automatically discovered by compatible agents. If a skill doesn't activate:

1. Check the description includes relevant keywords
2. Verify `name` matches directory name
3. Ensure YAML frontmatter is valid
4. Try more specific prompts
5. Check agent supports Agent Skills format

## License

Skills in this repository follow the same license as the ops-runbooks project.
