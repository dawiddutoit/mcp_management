#!/bin/bash

# Script to update global CLAUDE.md with project-aware MCP setup

CLAUDE_MD="$HOME/.claude/CLAUDE.md"

echo "📝 Updating global CLAUDE.md with project-aware MCP setup"
echo "========================================================"
echo

if [ ! -f "$CLAUDE_MD" ]; then
    echo "❌ Error: $CLAUDE_MD not found"
    exit 1
fi

# Create backup
cp "$CLAUDE_MD" "$CLAUDE_MD.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Created backup of CLAUDE.md"

# Replace the old MCP section with the new one
cat > /tmp/new_mcp_section.txt << 'EOF'
### MCP Server Management

For project-specific MCP server configuration:

```bash
# Setup MCP servers for current project (recommended)
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup

# Or initialize for a new project
/Users/dawiddutoit/projects/play/mcp_management/init-project-mcp.sh

# Check current configuration
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh show
```

**Benefits of Project-Aware Setup:**
- Filesystem MCP gets access to current project directory
- Git MCP is scoped to current repository
- Easy switching between projects
- Maintains backward compatibility

**Legacy Global Setup (if needed):**
```bash
# Navigate to MCP management tools
cd ~/projects/play/mcp_management/

# Setup all MCP servers (run once per system)
./setup-mcp.sh setup

# Check current configuration
./setup-mcp.sh list

# Verify server status
./setup-mcp.sh status
```

**Required Actions at Session Start:**
1. **Run project-aware setup** if working on a specific project
2. **Verify connectivity** to ensure servers are accessible
3. **Report status** to user if servers were started or if any issues occurred
4. **Proceed with normal workflow** once MCP infrastructure is confirmed running

This ensures all MCP-dependent tools and workflows have the necessary server infrastructure available for the current project context.
EOF

# Use sed to replace the content between the markers
# This is a bit complex but preserves the rest of the file
perl -i -pe 'BEGIN{undef $/;} s/### MCP Server Management.*?(?=\n## |\z)/`cat \/tmp\/new_mcp_section.txt`/smge' "$CLAUDE_MD"

echo "✅ Updated CLAUDE.md with project-aware MCP setup"
echo
echo "Changes made:"
echo "- Added project-aware setup as primary method"
echo "- Moved legacy global setup to secondary position"
echo "- Added benefits section"
echo "- Updated required actions"
echo
echo "Backup saved to: $CLAUDE_MD.backup.$(date +%Y%m%d_%H%M%S)"

# Clean up
rm /tmp/new_mcp_section.txt