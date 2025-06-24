# Project-Aware MCP Setup Guide

## Quick Reference

### For New Projects
```bash
cd /path/to/your/new/project
/Users/dawiddutoit/projects/play/mcp_management/init-project-mcp.sh
```

### For Existing Projects
```bash
cd /path/to/your/existing/project
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup
```

### Switching Between Projects
```bash
# Simply run setup in the new project directory
cd /path/to/different/project
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup
```

## What Gets Configured

When you run the project-aware setup, the following MCP servers are configured:

1. **filesystem** - Gets access to:
   - `/Users/dawiddutoit/projects` (general projects directory)
   - Current project directory (e.g., `/Users/dawiddutoit/projects/play/prompter`)

2. **git** - Configured for:
   - Current git repository only (if it's a git repo)

3. **Other servers** remain globally configured:
   - think-tool
   - sequential-thinking
   - memory
   - jetbrains
   - desktop-commander
   - podman

## Common Use Cases

### Setting Up a New Node.js Project
```bash
mkdir my-new-app
cd my-new-app
npm init -y
git init
/Users/dawiddutoit/projects/play/mcp_management/init-project-mcp.sh
```

### Setting Up a New Python Project
```bash
mkdir my-python-project
cd my-python-project
python -m venv venv
git init
/Users/dawiddutoit/projects/play/mcp_management/init-project-mcp.sh
```

### Working on Multiple Projects
```bash
# Morning: Work on project A
cd ~/projects/project-a
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup

# Afternoon: Switch to project B
cd ~/projects/project-b
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup
```

## Troubleshooting

### "Not a git repository" warning
This is just a warning. The setup will still work, but the git MCP server won't be configured. To fix:
```bash
git init
# Then run setup again
```

### MCP servers not responding
1. Check configuration: `claude mcp list`
2. Restart Claude Code
3. Re-run the setup script

### Permission denied errors
```bash
chmod +x /Users/dawiddutoit/projects/play/mcp_management/*.sh
```

## Integration with CLAUDE.md

Add this to your project's CLAUDE.md file to remind AI assistants about MCP setup:

```markdown
### MCP Server Management

If MCP servers are not available or need to be configured for this project:

```bash
# Setup MCP servers for this specific project
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup
```

This ensures filesystem and git MCP servers have proper access to this project.
```

## Best Practices

1. **Run setup when starting work** on a new project
2. **Include in onboarding docs** for team projects
3. **Add to project README** for open source projects
4. **Create aliases** for convenience:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   alias mcp-setup='/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup'
   alias mcp-init='/Users/dawiddutoit/projects/play/mcp_management/init-project-mcp.sh'
   ```

## Security Notes

- Filesystem access is limited to specified directories
- Each project setup overwrites the previous configuration
- No credentials or sensitive data are stored
- MCP servers run with your user permissions

## Future Enhancements

Consider these improvements:
- Project-specific MCP server configurations
- Team-shared MCP configurations
- Project templates with pre-configured MCP setups
- Automatic detection of project type and relevant MCP servers