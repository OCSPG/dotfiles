#!/usr/bin/env bash

# Config files installer

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SRC="$DOTFILES_DIR/config"
CONFIG_DEST="$HOME/.config"

# Create backup of existing config
backup_if_exists() {
    local file=$1
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  ! Backing up existing $(basename "$file") to $(basename "$backup")"
        mv "$file" "$backup"
    fi
}

# Install config files
echo "==> Installing config files to ~/.config..."
echo ""
sleep 1

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
            echo "  ✓ Installed $config"
        else
            echo "  ✗ Failed to install $config"
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
            echo "  ✓ Installed $config_file"
        else
            echo "  ✗ Failed to install $config_file"
        fi
    done
}

clear
echo "==> Installing config directories..."
echo ""
install_config_dirs
echo ""
sleep 1

clear
echo "==> Installing config files..."
echo ""
install_config_files
echo ""
sleep 1

echo "  [INFO] Config installation complete"