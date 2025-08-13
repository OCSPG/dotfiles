#!/usr/bin/env bash

# Setup script - runs necessary system setup after packages are installed

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_DIR="$DOTFILES_DIR/setup"

# Function to prompt for yes/no
confirm() {
    local prompt=$1
    local default=${2:-n}
    
    # Check if running in non-interactive mode
    if [[ ! -t 0 ]]; then
        echo "  [INFO] $prompt (auto-choosing: $default)"
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

echo "==> System Setup"
echo "  [INFO] Running essential system setup tasks"
echo ""
sleep 1

# Run all setup scripts found in the setup directory
for script_path in "$SETUP_DIR"/*.sh; do
    [[ -f "$script_path" ]] || continue
    
    script=$(basename "$script_path")
    clear
    echo "==> Running setup: $script"
    echo ""
    sleep 1
    if bash "$script_path"; then
        echo "  ✓ Completed: $script"
    else
        echo "  ! Setup script $script returned non-zero exit code"
    fi
    echo ""
    sleep 2
done

echo "  ✓ System setup completed!"