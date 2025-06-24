#!/bin/bash

# Auto-detect and setup MCP servers for Claude Code sessions
# This script intelligently configures MCP based on current context

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Detect current project directory
detect_project_dir() {
    local current_dir="$PWD"
    
    # Check if we're in a git repository
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        echo "$(git rev-parse --show-toplevel)"
        return 0
    fi
    
    # Fallback to current working directory
    echo "$current_dir"
}

# Check if project is already in filesystem MCP config
check_project_in_mcp() {
    local project_dir="$1"
    local current_config=$(claude mcp list 2>/dev/null | grep "filesystem:" || echo "")
    
    if [[ -z "$current_config" ]]; then
        return 1  # No filesystem MCP configured
    fi
    
    # Check if project directory is already in the filesystem paths
    if echo "$current_config" | grep -q "$project_dir"; then
        return 0  # Project already configured
    else
        return 1  # Project not in config
    fi
}

# Setup project-aware MCP (from setup-project-mcp.sh)
setup_project_mcp() {
    local project_dir="$1"
    local projects_root="/Users/dawiddutoit/projects"
    
    print_info "Setting up project-aware MCP for: $project_dir"
    
    # Remove existing servers first
    local servers=($(claude mcp list 2>/dev/null | cut -d':' -f1 | tr -d ' '))
    for server in "${servers[@]}"; do
        if [[ -n "$server" ]]; then
            claude mcp remove "$server" -s user 2>/dev/null || true
        fi
    done
    
    # Add all MCP servers with project awareness
    claude mcp add "think-tool" "npx" "@cgize/mcp-think-tool" -s user 2>/dev/null
    claude mcp add "sequential-thinking" "npx" "@modelcontextprotocol/server-sequential-thinking" -s user 2>/dev/null
    claude mcp add "memory" "npx" "@modelcontextprotocol/server-memory" -s user 2>/dev/null
    claude mcp add "jetbrains" "npx" "@jetbrains/mcp-proxy" -s user 2>/dev/null
    claude mcp add "desktop-commander" "npx" "@wonderwhy-er/desktop-commander@latest" -s user 2>/dev/null
    claude mcp add "podman" "npx" "podman-mcp-server@latest" -s user 2>/dev/null
    claude mcp add "filesystem" "npx" "@modelcontextprotocol/server-filesystem" "$projects_root" "$project_dir" -s user 2>/dev/null
    
    # Add git server if in git repo
    if git -C "$project_dir" rev-parse --git-dir >/dev/null 2>&1; then
        claude mcp add "git" "uvx" "mcp-server-git" "$project_dir" -s user 2>/dev/null
    fi
    
    print_status "Project-aware MCP setup complete"
}

# Setup global MCP as fallback
setup_global_mcp() {
    print_info "Using global MCP configuration"
    
    # This would be the original global setup
    /Users/dawiddutoit/projects/play/mcp_management/setup-mcp.sh setup 2>/dev/null || {
        print_error "Failed to setup global MCP configuration"
        return 1
    }
}

# Main logic
main() {
    echo "🤖 Claude Code MCP Auto-Setup"
    echo "=============================="
    echo
    
    # Try to detect if we're in a project
    local current_dir="$PWD"
    local project_dir=$(detect_project_dir)
    
    # Check if we're in a recognizable project directory
    if [[ "$current_dir" == "$HOME" ]] || [[ "$current_dir" == "/" ]]; then
        print_info "Not in a project directory, using global MCP settings"
        setup_global_mcp
        return 0
    fi
    
    # Check if project is already configured
    if check_project_in_mcp "$project_dir"; then
        print_status "Project already configured in filesystem MCP"
        print_info "Current project: $project_dir"
        return 0
    fi
    
    # Try to setup project-aware MCP
    if setup_project_mcp "$project_dir"; then
        print_status "Successfully configured MCP for project: $project_dir"
    else
        print_warning "Failed to setup project MCP, falling back to global configuration"
        setup_global_mcp
    fi
    
    echo
    print_info "MCP servers ready for use"
}

# Run with error handling
{
    main "$@"
} || {
    print_error "MCP setup encountered an error"
    print_info "You can manually run: mcp-setup"
    exit 1
}