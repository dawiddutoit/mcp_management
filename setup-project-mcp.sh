#!/bin/bash

# Project-Aware MCP Server Configuration Script
# Configures MCP servers using config.json as source of truth
# Supports project-local configuration overrides

set -e

echo "🎯 Project-Aware MCP Server Setup"
echo "=================================="
echo

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

# Function to substitute variables in config
substitute_variables() {
    local config_content="$1"
    local project_dir="$2"
    
    # Replace {{PROJECT_DIR}} with actual project directory
    echo "$config_content" | sed "s|{{PROJECT_DIR}}|$project_dir|g"
}

# Function to merge configurations
merge_configs() {
    local global_config="$1"
    local project_config="$2"
    local project_dir="$3"
    
    # If no project config exists, just substitute variables in global config
    if [[ ! -f "$project_config" ]]; then
        substitute_variables "$(cat "$global_config")" "$project_dir"
        return 0
    fi
    
    print_info "Found project-local config: $project_config"
    
    # Create temporary files for processing
    local temp_global=$(mktemp)
    local temp_project=$(mktemp)
    local temp_merged=$(mktemp)
    
    # Substitute variables in both configs
    substitute_variables "$(cat "$global_config")" "$project_dir" > "$temp_global"
    substitute_variables "$(cat "$project_config")" "$project_dir" > "$temp_project"
    
    # Merge configurations (project config overrides global)
    jq -s '.[0] * .[1]' "$temp_global" "$temp_project" > "$temp_merged"
    
    cat "$temp_merged"
    
    # Cleanup
    rm -f "$temp_global" "$temp_project" "$temp_merged"
}

# Function to read and merge configuration files
read_merged_config() {
    local project_dir="$1"
    local global_config="$(dirname "$0")/config.json"
    local project_config="$project_dir/.mcp-config.json"
    
    if [[ ! -f "$global_config" ]]; then
        print_error "Global config file not found: $global_config"
        return 1
    fi
    
    merge_configs "$global_config" "$project_config" "$project_dir"
}

# Function to add MCP server with error handling
add_mcp_server() {
    local name="$1"
    local command="$2"
    shift 2
    local args=("$@")
    
    print_info "Adding MCP server: $name"
    
    if claude mcp add "$name" "$command" "${args[@]}" -s user; then
        print_status "Successfully added $name"
        return 0
    else
        print_error "Failed to add $name"
        return 1
    fi
}

# Function to setup project-aware MCP servers
setup_project_mcp() {
    local project_dir="$1"
    
    print_info "Project directory: $project_dir"
    echo
    
    print_info "Reading merged configuration..."
    local merged_config=$(read_merged_config "$project_dir")
    
    if [[ -z "$merged_config" ]]; then
        print_error "Failed to read configuration"
        return 1
    fi
    
    print_info "Removing existing MCP servers..."
    
    # Remove existing servers first
    local servers=($(claude mcp list | cut -d':' -f1 | tr -d ' '))
    for server in "${servers[@]}"; do
        if [[ -n "$server" ]]; then
            claude mcp remove "$server" -s user 2>/dev/null || true
        fi
    done
    
    print_status "Existing servers removed"
    echo
    
    print_info "Setting up MCP servers from configuration..."
    echo
    
    local success_count=0
    local total_count=0
    
    # Parse merged config and setup each server
    while IFS= read -r server_name; do
        if [[ -n "$server_name" && "$server_name" != "null" ]]; then
            ((total_count++))
            
            local command=$(echo "$merged_config" | jq -r ".mcpServers.\"$server_name\".command")
            local args_json=$(echo "$merged_config" | jq -r ".mcpServers.\"$server_name\".args | @json")
            local args=()
            
            # Parse args array from JSON
            while IFS= read -r arg; do
                args+=("$arg")
            done < <(echo "$args_json" | jq -r '.[]')
            
            # Skip git server if not in a git repository
            if [[ "$server_name" == "git" ]] && ! git -C "$project_dir" rev-parse --git-dir >/dev/null 2>&1; then
                print_warning "Not a git repository, skipping git MCP server"
                ((total_count--))
                continue
            fi
            
            if add_mcp_server "$server_name" "$command" "${args[@]}"; then
                ((success_count++))
            fi
            echo
        fi
    done < <(echo "$merged_config" | jq -r '.mcpServers | keys[]')
    
    echo "============================"
    print_status "Project-aware MCP setup complete: $success_count/$total_count servers configured"
    echo
}

# Function to initialize MCP for a new project
init_project() {
    local project_dir="$1"
    
    if [[ -z "$project_dir" ]]; then
        project_dir="$PWD"
    fi
    
    if [[ ! -d "$project_dir" ]]; then
        print_error "Project directory does not exist: $project_dir"
        exit 1
    fi
    
    cd "$project_dir"
    local resolved_project_dir="$PWD"
    
    print_info "Initializing MCP servers for project: $resolved_project_dir"
    setup_project_mcp "$resolved_project_dir"
}

# Function to show current project configuration
show_project_config() {
    local project_dir=$(detect_project_dir)
    
    echo "Current Project MCP Configuration:"
    echo "================================="
    echo "Project directory: $project_dir"
    echo
    
    echo "Active MCP servers:"
    claude mcp list
    echo
}

# Main script logic
main() {
    case "${1:-auto}" in
        "init")
            init_project "$2"
            ;;
        "setup")
            local project_dir=$(detect_project_dir)
            setup_project_mcp "$project_dir"
            ;;
        "show"|"list")
            show_project_config
            ;;
        "auto")
            # Auto-detect and setup
            local project_dir=$(detect_project_dir)
            setup_project_mcp "$project_dir"
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command] [options]"
            echo
            echo "Commands:"
            echo "  auto       Auto-detect project and setup MCP servers (default)"
            echo "  setup      Setup MCP servers for current project"
            echo "  init DIR   Initialize MCP servers for specific directory"
            echo "  show       Show current project MCP configuration"
            echo "  help       Show this help message"
            echo
            exit 0
            ;;
        *)
            print_error "Unknown command: $1"
            print_info "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"