#!/bin/bash

# Script to update CLAUDE.md files with automatic MCP setup instructions

echo "📝 Updating CLAUDE.md with automatic MCP setup"
echo "=============================================="
echo

# Function to update a CLAUDE.md file
update_claude_md() {
    local claude_md="$1"
    local is_global="$2"
    
    if [ ! -f "$claude_md" ]; then
        echo "❌ Error: $claude_md not found"
        return 1
    fi
    
    # Create backup
    cp "$claude_md" "$claude_md.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✅ Created backup of $(basename $claude_md)"
    
    # Prepare the new MCP section content
    if [ "$is_global" = "true" ]; then
        # Global CLAUDE.md content
        cat > /tmp/new_mcp_section.txt << 'EOF'
### MCP Server Management

**Automatic Project-Aware Setup (Recommended)**

At the start of each Claude Code session, run:

```bash
# Auto-detect project and configure MCP appropriately
/Users/dawiddutoit/projects/play/mcp_management/auto-setup-mcp.sh
```

This script will:
1. Detect if you're in a project directory
2. Check if the project is already configured in filesystem MCP
3. Setup project-aware MCP if needed
4. Fall back to global settings if not in a project

**Manual Project-Specific Setup**

For explicit project configuration:

```bash
# Setup MCP servers for current project
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
1. **Run auto-setup script** to ensure proper MCP configuration
2. **Verify connectivity** to ensure servers are accessible
3. **Report status** to user if servers were started or if any issues occurred
4. **Proceed with normal workflow** once MCP infrastructure is confirmed running

This ensures all MCP-dependent tools and workflows have the necessary server infrastructure available for the current project context.
EOF
    else
        # Project CLAUDE.md content
        cat > /tmp/new_mcp_section.txt << 'EOF'
### MCP Server Management

If MCP servers are not available or need to be configured for this project, run:

```bash
# Auto-detect and setup MCP for current project
/Users/dawiddutoit/projects/play/mcp_management/auto-setup-mcp.sh

# Or manually setup for this specific project
/Users/dawiddutoit/projects/play/mcp_management/setup-project-mcp.sh setup
```

The auto-setup script will:
- Detect this project directory
- Configure filesystem MCP to include this project
- Setup git MCP for this repository
- Ensure all other MCP servers are available

This ensures filesystem and git MCP servers have proper access to this project.
EOF
    fi
    
    # Check if MCP section exists
    if grep -q "### MCP Server Management" "$claude_md"; then
        # Replace existing section
        perl -i -pe 'BEGIN{undef $/;} s/### MCP Server Management.*?(?=\n## |\n# |\z)/`cat \/tmp\/new_mcp_section.txt`/smge' "$claude_md"
        echo "✅ Updated existing MCP section in $(basename $claude_md)"
    else
        # Append new section
        echo "" >> "$claude_md"
        cat /tmp/new_mcp_section.txt >> "$claude_md"
        echo "✅ Added MCP section to $(basename $claude_md)"
    fi
    
    # Clean up
    rm -f /tmp/new_mcp_section.txt
}

# Main execution
main() {
    # Update global CLAUDE.md
    echo "Updating global CLAUDE.md..."
    update_claude_md "$HOME/.claude/CLAUDE.md" "true"
    echo
    
    # Check if we're in a project with local CLAUDE.md
    if [ -f "./CLAUDE.md" ]; then
        echo "Updating project CLAUDE.md..."
        update_claude_md "./CLAUDE.md" "false"
        echo
    fi
    
    echo "✅ CLAUDE.md files updated with automatic MCP setup instructions"
    echo
    echo "Next steps:"
    echo "1. Start new Claude Code sessions with auto-setup:"
    echo "   /Users/dawiddutoit/projects/play/mcp_management/auto-setup-mcp.sh"
    echo
    echo "2. Or add this alias to your shell config:"
    echo "   alias claude-start='/Users/dawiddutoit/projects/play/mcp_management/auto-setup-mcp.sh'"
}

# Run main function
main "$@"