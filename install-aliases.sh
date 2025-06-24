#!/bin/bash

# Script to install convenient MCP management aliases

echo "🚀 Installing MCP Management Aliases"
echo "===================================="
echo

# Detect shell configuration file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    echo "⚠️  Unsupported shell. Please add aliases manually."
    exit 1
fi

echo "Detected shell: $SHELL_NAME"
echo "Config file: $SHELL_CONFIG"
echo

# Define aliases
ALIASES="
# MCP Management Aliases
alias mcp-auto='$PWD/auto-setup-mcp.sh'
alias mcp-setup='$PWD/setup-project-mcp.sh setup'
alias mcp-init='$PWD/init-project-mcp.sh'
alias mcp-show='$PWD/setup-project-mcp.sh show'
alias mcp-global='$PWD/setup-mcp.sh'
alias claude-start='$PWD/auto-setup-mcp.sh'
"

# Check if aliases already exist
if grep -q "MCP Management Aliases" "$SHELL_CONFIG" 2>/dev/null; then
    echo "⚠️  MCP aliases already installed in $SHELL_CONFIG"
    echo "   Remove them manually if you want to reinstall."
    exit 0
fi

# Add aliases to shell config
echo "Adding aliases to $SHELL_CONFIG..."
echo "$ALIASES" >> "$SHELL_CONFIG"

echo "✅ Aliases installed successfully!"
echo
echo "Available commands after reloading shell:"
echo "  mcp-auto   - Auto-detect and setup MCP (recommended at session start)"
echo "  mcp-setup  - Setup MCP for current project"
echo "  mcp-init   - Initialize MCP for new project"
echo "  mcp-show   - Show current MCP configuration"
echo "  mcp-global - Access global MCP management menu"
echo "  claude-start - Alias for mcp-auto (easy to remember)"
echo
echo "To activate now, run:"
echo "  source $SHELL_CONFIG"
echo