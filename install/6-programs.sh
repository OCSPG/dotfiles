#!/usr/bin/env bash

# User programs installer
set -e

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROGRAMS_SRC="$DOTFILES_DIR/programs"
BIN_DEST="$HOME/.local/bin"

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

# Create backup of existing file
backup_if_exists() {
    local file=$1
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $(basename "$file") to $(basename "$backup")"
        mv "$file" "$backup"
    fi
}

# Install programs
print_info "Installing user programs to ~/.local/bin..."

# Create destination directory if it doesn't exist
mkdir -p "$BIN_DEST"

# Check if .local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    print_warning "~/.local/bin is not in your PATH"
    print_info "Add this line to your shell config:"
    print_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
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
            print_success "Installed $program"
        else
            print_error "Failed to install $program"
        fi
    done
}

# Install all programs
install_programs

# Also create ~/bin directory and install clip2path there if it doesn't exist
# (for compatibility with the original setup)
if [[ -f "$PROGRAMS_SRC/clip2path" ]]; then
    print_info "Installing clip2path to ~/bin for compatibility..."
    mkdir -p "$HOME/bin"
    backup_if_exists "$HOME/bin/clip2path"
    if cp "$PROGRAMS_SRC/clip2path" "$HOME/bin/"; then
        chmod +x "$HOME/bin/clip2path"
        print_success "Installed clip2path to ~/bin"
    else
        print_warning "Failed to install clip2path to ~/bin"
    fi
fi

print_info "User programs installation complete"