# GitHub Copilot Agents for ops-runbooks

This directory contains custom GitHub Copilot agent definitions that help with creating and maintaining operational runbooks for HMCTS Platform Operations.

## Available Agents

### @runbook-scaffolder
**Purpose**: Creates new runbook documents with proper structure and formatting.

**Use Cases**:
- Generate new runbook files with correct YAML frontmatter
- Create standardized section templates based on runbook type
- Suggest appropriate directory placement
- Generate index pages for new sections

**Example Usage**:
```
@runbook-scaffolder create a troubleshooting guide for Prometheus alerts
@runbook-scaffolder generate an upgrade procedure runbook for Traefik
@runbook-scaffolder create an index page for the new Security section
```

**Learn More**: See [runbook-scaffolder.md](./runbook-scaffolder.md)

## Future Agents (Planned)

### @doc-reviewer
- Identifies runbooks past their review date
- Checks for broken links
- Validates command syntax
- Flags outdated Kubernetes versions

### @command-validator
- Validates kubectl, az, terraform, helm commands
- Checks for deprecated APIs
- Suggests best practices

### @pr-finder
- Searches for relevant PR examples
- Updates outdated PR links
- Generates PR reference snippets

### @cross-env-checker
- Ensures CFT/SDS consistency
- Identifies missing environment variants
- Maps cluster relationships

## How to Use

1. **Invoke an agent**: Type `@agent-name` followed by your request in GitHub Copilot Chat
2. **Be specific**: Provide details about what you need (topic, type, environment)
3. **Review output**: Always review generated content for accuracy
4. **Customize**: Treat generated content as a starting point

## Agent Architecture

Each agent definition includes:
- **Description**: What the agent does
- **Capabilities**: Specific tasks it can perform
- **Input Requirements**: What information it needs
- **Output Format**: Templates and structures it generates
- **Common Patterns**: Reusable patterns specific to this repo
- **Best Practices**: Guidelines for quality output
- **Example Usage**: Sample interactions

## Contributing

To add or improve agents:

1. Create or update an agent definition file in this directory
2. Follow the structure of existing agents
3. Include comprehensive examples and patterns
4. Test with various scenarios
5. Update this README with the new agent

## Workspace Context

All agents have access to:
- Repository structure and conventions
- Existing runbooks as examples
- HMCTS-specific patterns (cluster names, environments, repo URLs)
- Tech docs configuration
- Style guide and contribution guidelines

## Best Practices

- Always review generated content before committing
- Customize templates to fit specific use cases
- Keep agent definitions updated as conventions evolve
- Provide feedback on agent performance
- Share useful prompts with the team

## Support

If an agent doesn't work as expected:
1. Check your prompt is clear and specific
2. Review the agent's documentation for input requirements
3. Try rephrasing your request
4. Check the agent definition file for examples
5. Raise an issue or update the agent definition

## Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Contribution Guide](../../source/Contribution-Guide/index.html.md.erb)
- [Tech Docs Configuration](../../config/tech-docs.yml)
- [Main README](../../README.md)
