# GitHub Copilot Skills for ops-runbooks

This directory contains skills that provide specialized knowledge and templates for creating HMCTS operational runbooks.

## Architecture

Skills are used by agents:
- **Agent** (`.github/agents/`) - User-facing persona that asks questions and coordinates
- **Skill** (`.github/skills/`) - Provides templates, patterns, and domain knowledge

## Available Skills

### Runbook Scaffolder
**File**: `runbook-scaffolder/SKILL.md`

**Purpose**: Provides templates, patterns, and conventions for HMCTS runbook creation

**Used by**: Runbook Creator Agent (`.github/agents/runbook-creator-agent.md`)

**Contains**:
- File naming conventions (`.html.md.erb` extension rules)
- YAML frontmatter templates
- Contribution guide integration instructions
- HMCTS-specific patterns:
  - Cluster naming (cft-*, ss-*, prod-*)
  - Environment progression (Sbox → PTL)
  - Repository references
  - PR example formats
- kubectl queries and helm operations
- Verification checklists
- Rollback procedures
- Command formatting examples

**Key Features**:
- Reads contribution guides: `source/Contribution-Guide/`
- Uses official templates: `source/Contribution-Guide/guide-examples/`
- Template types: how-to, troubleshooting, maintenance
- Ensures correct file extension (`.html.md.erb` not `.md`)
- Follows weight increment rules (by 10)
- Includes verification and testing steps

**Reference Files**:
- `references/PATTERNS.md` - Common patterns and reusable snippets
- `references/EXAMPLES.md` - Complete runbook examples

## How Skills Work

1. **User invokes agent**: "@runbook-creator create a guide for..."
2. **Agent reads contribution guides**: Gets official templates and rules
3. **Agent activates skill**: Uses runbook-scaffolder for patterns and conventions
4. **Skill provides**: Templates, HMCTS patterns, verification checklists
5. **Agent implements**: Creates file with proper structure
6. **Agent returns**: Testing instructions and next steps

## Contribution Guide Integration

This skill ensures all runbooks follow:
- `source/Contribution-Guide/index.html.md.erb` - Main guide
- `source/Contribution-Guide/addingpages.html.md.erb` - File creation rules
- `source/Contribution-Guide/guide-examples/` - Official templates
- `source/Contribution-Guide/testing.html.md.erb` - Testing procedures

## Usage

Skills are activated automatically by agents. You don't call skills directly - use the agent instead:

```
@runbook-creator create a troubleshooting guide for DNS issues
```

The agent will use the runbook-scaffolder skill to provide patterns and templates.

See [`.github/agents/README.md`](../agents/README.md) for complete usage instructions.

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
