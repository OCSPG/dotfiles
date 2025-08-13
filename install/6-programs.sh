#!/usr/bin/env bash

# User programs installer

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRAMS_SRC="$DOTFILES_DIR/programs"
BIN_DEST="$HOME/.local/bin"

# Create backup of existing file
backup_if_exists() {
    local file=$1
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  ! Backing up existing $(basename "$file") to $(basename "$backup")"
        mv "$file" "$backup"
    fi
}

# Install programs
echo "==> Installing user programs to ~/.local/bin..."
echo ""
sleep 1

# Create destination directory if it doesn't exist
mkdir -p "$BIN_DEST"

# Check if .local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "  ! ~/.local/bin is not in your PATH"
    echo "  [INFO] Add this line to your shell config:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Function to install programs
install_programs() {
    for src_file in "$PROGRAMS_SRC"/*; do
        [[ -f "$src_file" ]] || continue
        
        local program=$(basename "$src_file")
        local dest="$BIN_DEST/$program"
        
        # Backup existing program
        backup_if_exists "$dest"
        
        # Copy program
        if cp "$src_file" "$dest"; then
            # Ensure it's executable
            chmod +x "$dest"
            echo "  ✓ Installed $program"
        else
            echo "  ✗ Failed to install $program"
        fi
    done
}

clear
echo "==> Installing programs..."
echo ""
install_programs
echo ""
sleep 1

echo "  [INFO] User programs installation complete"