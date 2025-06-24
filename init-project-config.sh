#!/bin/bash

# Project Config Initialization Script
# Creates project-local MCP configuration files

set -e

echo "📝 Project MCP Config Initializer"
echo "================================="
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

# Initialize project config
init_project_config() {
    local project_dir="${1:-$PWD}"
    local config_file="$project_dir/.mcp-config.json"
    local template_file="$(dirname "$0")/project-config.template.json"
    
    if [[ ! -f "$template_file" ]]; then
        print_error "Template file not found: $template_file"
        return 1
    fi
    
    if [[ -f "$config_file" ]]; then
        print_warning "Project config already exists: $config_file"
        read -p "Overwrite existing config? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled"
            return 0
        fi
    fi
    
    print_info "Creating project config: $config_file"
    cp "$template_file" "$config_file"
    
    print_status "Project config created!"
    print_info "Edit $config_file to customize your project's MCP servers"
    echo
    print_info "Common customizations:"
    echo "  - Add additional filesystem paths to the filesystem server"
    echo "  - Add project-specific MCP servers"
    echo "  - Override global server configurations"
    echo
}

# Show current project config
show_project_config() {
    local project_dir="${1:-$PWD}"
    local config_file="$project_dir/.mcp-config.json"
    
    if [[ ! -f "$config_file" ]]; then
        print_warning "No project config found: $config_file"
        print_info "Run '$0 init' to create one"
        return 0
    fi
    
    print_info "Project config: $config_file"
    echo
    cat "$config_file"
}

# Main script logic
main() {
    case "${1:-help}" in
        "init")
            init_project_config "$2"
            ;;
        "show"|"cat")
            show_project_config "$2"
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command] [project_dir]"
            echo
            echo "Commands:"
            echo "  init [DIR]  Initialize .mcp-config.json in project directory"
            echo "  show [DIR]  Show current project configuration"
            echo "  help        Show this help message"
            echo
            echo "If no directory is specified, uses current working directory."
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