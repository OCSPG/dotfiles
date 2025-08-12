#!/usr/bin/env bash

# Setup script - runs necessary system setup after packages are installed
set -e

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="$DOTFILES_DIR/setup"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "  ${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}!${NC} $1"
}

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

# Function to prompt for yes/no
confirm() {
    local prompt=$1
    local default=${2:-n}
    
    # Check if running in non-interactive mode
    if [[ ! -t 0 ]]; then
        print_info "$prompt (auto-choosing: $default)"
        [[ "$default" == "y" ]] && return 0 || return 1
    fi
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi
    
    read -p "$prompt" -n 1 -r
    echo ""
    
    if [[ "$default" == "y" ]]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
    else
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

print_step "System Setup"
print_info "Running essential system setup tasks"
echo ""

# Run all setup scripts found in the setup directory
for script_path in "$SETUP_DIR"/*.sh; do
    [[ -f "$script_path" ]] || continue
    
    script=$(basename "$script_path")
    print_info "Running setup: $script"
    if bash "$script_path"; then
        print_success "Completed: $script"
    else
        print_warning "Setup script $script returned non-zero exit code"
    fi
    echo ""
done

print_success "System setup completed!"