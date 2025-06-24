#!/bin/bash

# Simple script to initialize MCP servers for a new project
# This should be run from within the new project directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_SETUP_SCRIPT="$SCRIPT_DIR/setup-project-mcp.sh"

echo "🚀 Initializing MCP servers for new project..."
echo "=============================================="
echo

# Check if we're in a directory that looks like a project
if [[ ! -f "package.json" && ! -f "Cargo.toml" && ! -f "pyproject.toml" && ! -f ".git/config" && ! -f "go.mod" ]]; then
    echo "⚠️  Warning: This doesn't look like a typical project directory."
    echo "   No package.json, Cargo.toml, pyproject.toml, .git, or go.mod found."
    echo
    read -p "Continue anyway? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Run the project-aware setup
"$PROJECT_SETUP_SCRIPT" setup

echo
echo "✅ MCP servers initialized for this project!"
echo
echo "Next steps:"
echo "1. Your MCP servers now have access to this project directory"
echo "2. The filesystem server can read/write files in this project"
echo "3. The git server (if applicable) is configured for this repository"
echo
echo "To reconfigure MCP servers for a different project, run:"
echo "  $PROJECT_SETUP_SCRIPT setup"
echo