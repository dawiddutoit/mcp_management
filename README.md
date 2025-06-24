# MCP Management Tool

A comprehensive tool to manage Model Context Protocol (MCP) servers for Claude Code with project-aware configuration.

## Features

- **Setup all MCP servers** at user level for cross-project availability
- **Project-aware configuration** - automatically includes current project directory
- **List current configuration** to see what's installed
- **Remove all servers** for clean slate setup
- **Backup configuration** before making changes
- **Check server status** to see running processes
- **Interactive menu** or command-line usage
- **New project initialization** - easy setup for new projects

## Quick Start

### Automatic Setup (Recommended)
```bash
# Auto-detect and configure MCP for your current context
./auto-setup-mcp.sh
```

This intelligent script will:
- Detect if you're in a project directory
- Check if the project is already configured
- Setup project-aware MCP if needed
- Fall back to global settings when not in a project

### Manual Setup Options
```bash
# Setup MCP servers for current project
./setup-project-mcp.sh setup

# Or use the original global setup
./setup-mcp.sh setup
```

### For New Projects
```bash
# From within your new project directory
/path/to/mcp_management/init-project-mcp.sh
```

### Traditional Global Setup
```bash
# Make script executable
chmod +x setup-mcp.sh

# Run interactively
./setup-mcp.sh

# Or use command-line options
./setup-mcp.sh setup    # Setup all servers
./setup-mcp.sh list     # List current servers
./setup-mcp.sh status   # Check running processes
```

## MCP Servers Included

| Server                  | Purpose                      | Command                                                       |
|-------------------------|------------------------------|---------------------------------------------------------------|
| **think-tool**          | AI thinking capabilities     | `npx @cgize/mcp-think-tool`                                   |
| **filesystem**          | File system access           | `npx @modelcontextprotocol/server-filesystem` (project-aware) |
| **jetbrains**           | JetBrains IDE integration    | `npx @jetbrains/mcp-proxy`                                    |
| **desktop-commander**   | Desktop automation           | `npx @wonderwhy-er/desktop-commander@latest`                  |
| **sequential-thinking** | Sequential thinking patterns | `npx @modelcontextprotocol/server-sequential-thinking`        |
| **memory**              | Persistent memory            | `npx @modelcontextprotocol/server-memory`                     |
| **podman**              | Container management         | `npx podman-mcp-server@latest`                                |
| **git**                 | Git repository operations    | `uvx mcp-server-git` (project-aware)                          |
| **github**              | GitHub API integration       | `docker run ghcr.io/github/github-mcp-server` (requires token) |

## Why User-Level Configuration?

- ✅ **Cross-project availability** - Works in all Claude Code projects
- ✅ **Persistent** - Survives project switches and updates
- ✅ **Centralized** - Single configuration to manage
- ✅ **Backup-friendly** - Easy to backup and restore

## Usage Examples

### Interactive Mode
```bash
./setup-mcp.sh
```
Provides a menu-driven interface for all operations.

### Command Line Mode
```bash
# Setup all servers
./setup-mcp.sh setup

# Check what's configured
./setup-mcp.sh list

# See running processes
./setup-mcp.sh status

# Backup before changes
./setup-mcp.sh backup

# Clean slate (removes all)
./setup-mcp.sh remove
```

## Automatic Project Detection

The `auto-setup-mcp.sh` script provides intelligent MCP configuration:

```bash
# At the start of each Claude Code session
./auto-setup-mcp.sh
```

### How It Works
1. **Project Detection**: Automatically detects if you're in a project (via git or working directory)
2. **Configuration Check**: Verifies if the project is already in filesystem MCP config
3. **Smart Setup**: Only reconfigures if needed, preserving existing setups
4. **Fallback Logic**: Uses global settings when not in a project directory

### Session Start Workflow
```bash
# Add to your shell config for easy access
alias claude-start='/path/to/mcp_management/auto-setup-mcp.sh'

# Then at each session start
claude-start
```

## Project-Aware Configuration

The project-aware setup automatically configures MCP servers to include your current project directory.

### Benefits
- ✅ **Filesystem access** to current project directory
- ✅ **Git operations** scoped to current repository
- ✅ **Automatic project detection** via git or working directory
- ✅ **Easy project switching** - just run the setup script in the new project

### Usage
```bash
# From any project directory
/path/to/mcp_management/setup-project-mcp.sh setup

# Show current project configuration
/path/to/mcp_management/setup-project-mcp.sh show

# Initialize MCP for a new project (run from within project)
/path/to/mcp_management/init-project-mcp.sh
```

## Manual Commands

If you prefer to run commands manually (example with current project paths):

```bash
# Add all servers individually (adjust paths for your project)
claude mcp add think-tool npx @cgize/mcp-think-tool -s user
claude mcp add filesystem npx @modelcontextprotocol/server-filesystem /Users/dawiddutoit/projects /Users/dawiddutoit/projects/play/prompter -s user
claude mcp add jetbrains npx @jetbrains/mcp-proxy -s user
claude mcp add desktop-commander npx @wonderwhy-er/desktop-commander@latest -s user
claude mcp add sequential-thinking npx @modelcontextprotocol/server-sequential-thinking -s user
claude mcp add memory npx @modelcontextprotocol/server-memory -s user
claude mcp add podman npx podman-mcp-server@latest -s user
claude mcp add git uvx mcp-server-git /Users/dawiddutoit/projects/play/prompter -s user
claude mcp add github docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server -s user
```

## GitHub MCP Server Setup

The GitHub MCP server provides GitHub API integration for repository management, issue tracking, and more.

### Prerequisites

1. **Docker**: The GitHub MCP server runs as a Docker container
2. **GitHub Personal Access Token**: Required for API authentication

### Setup Steps

#### 1. Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select appropriate scopes based on your needs:
   - `repo` - Full control of private repositories
   - `public_repo` - Access public repositories
   - `read:org` - Read org and team membership
   - `read:user` - Read user profile data
   - `user:email` - Access user email addresses

#### 2. Set Environment Variable

Add to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"
```

Or set it for the current session:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"
```

#### 3. Install via Setup Script

```bash
# The GitHub server is included in the default configuration
./setup-mcp.sh setup
```

#### 4. Manual Installation

```bash
claude mcp add github "docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server" -s user
```

### Usage Examples

Once configured, you can ask Claude to:

- List repositories in your GitHub account
- Create new repositories
- Manage issues and pull requests
- Search code across repositories
- Get repository statistics
- Manage GitHub Actions workflows

### Troubleshooting GitHub MCP Server

#### Token Issues
- Ensure `GITHUB_PERSONAL_ACCESS_TOKEN` is set in your environment
- Verify token has necessary permissions for the operations you want to perform
- Check token hasn't expired

#### Docker Issues
- Make sure Docker is running: `docker ps`
- Test the server manually: `docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server`

#### Configuration Issues
- Verify server is added: `claude mcp list | grep github`
- Remove and re-add if needed: `claude mcp remove github -s user`

## Troubleshooting

### Servers Not Working
1. Check if servers are configured: `./setup-mcp.sh list`
2. Check if processes are running: `./setup-mcp.sh status`
3. Try removing and re-adding: `./setup-mcp.sh remove` then `./setup-mcp.sh setup`

### Permission Issues
```bash
chmod +x setup-mcp.sh
```

### Backup and Restore
Always backup before making changes:
```bash
./setup-mcp.sh backup
```

Backups are saved as `mcp_backup_YYYYMMDD_HHMMSS.txt` in the same directory.

## Configuration Storage

MCP servers configured at user level are stored in Claude Code's user configuration, making them persistent across projects and less likely to be lost during updates.