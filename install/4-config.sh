#!/usr/bin/env bash

# Config files installer
set -e

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DEST="$HOME/.config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "  ${NC}$1${NC}"
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

# Create backup of existing config
backup_if_exists() {
    local file=$1
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $(basename "$file") to $(basename "$backup")"
        mv "$file" "$backup"
    fi
}

# Install config files
print_info "Installing config files to ~/.config..."

# Create .config directory if it doesn't exist
mkdir -p "$CONFIG_DEST"

# Function to install config directories
install_config_dirs() {
    for src_path in "$CONFIG_SRC"/*/; do
        [[ -d "$src_path" ]] || continue
        
        local config=$(basename "$src_path")
        local dest="$CONFIG_DEST/$config"
        
        # Backup existing config
        backup_if_exists "$dest"
        
        # Copy config
        if cp -r "$src_path" "$CONFIG_DEST/"; then
            print_success "Installed $config"
        else
            print_error "Failed to install $config"
        fi
    done
}

# Function to install config files
install_config_files() {
    for src_file in "$CONFIG_SRC"/*; do
        [[ -f "$src_file" ]] || continue
        
        local config_file=$(basename "$src_file")
        local dest_file="$CONFIG_DEST/$config_file"
        
        backup_if_exists "$dest_file"
        if cp "$src_file" "$CONFIG_DEST/"; then
            print_success "Installed $config_file"
        else
            print_error "Failed to install $config_file"
        fi
    done
}

# Install all config directories and files
install_config_dirs
install_config_files

print_info "Config installation complete"