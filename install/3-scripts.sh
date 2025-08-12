#!/usr/bin/env bash

# Scripts folder installer
set -e

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_SRC="$DOTFILES_DIR/scripts"
SCRIPTS_DEST="$HOME/scripts"

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

# Install scripts
print_info "Installing scripts to ~/scripts..."

# Check if scripts directory already exists
if [[ -d "$SCRIPTS_DEST" ]]; then
    print_warning "~/scripts already exists"
    
    # Check if it's a symlink
    if [[ -L "$SCRIPTS_DEST" ]]; then
        print_info "~/scripts is a symlink to: $(readlink "$SCRIPTS_DEST")"
    fi
    
    # Create backup
    backup_dir="${SCRIPTS_DEST}.backup.$(date +%Y%m%d_%H%M%S)"
    print_warning "Backing up existing scripts to $(basename "$backup_dir")"
    mv "$SCRIPTS_DEST" "$backup_dir"
fi

# Copy scripts directory
if cp -r "$SCRIPTS_SRC" "$SCRIPTS_DEST"; then
    print_success "Copied scripts directory"
else
    print_error "Failed to copy scripts directory"
    exit 1
fi

# Make all .sh files executable
print_info "Making shell scripts executable..."
find "$SCRIPTS_DEST" -type f -name "*.sh" -exec chmod +x {} \;
print_success "Made all .sh files executable"

# Check for symlinks in .local/bin that point to old Scripts location
print_info "Checking for existing symlinks in ~/.local/bin..."
if [[ -d "$HOME/.local/bin" ]]; then
    while IFS= read -r link; do
        target=$(readlink "$link")
        if [[ "$target" == *"/Scripts/"* ]] || [[ "$target" == *"/scripts/"* ]]; then
            basename=$(basename "$link")
            print_warning "Found symlink: $basename -> $target"
            
            # Check if the script exists in new location
            new_target="$SCRIPTS_DEST/${target##*/Scripts/}"
            new_target="${new_target##*/scripts/}"
            
            if [[ -f "$SCRIPTS_DEST/$new_target" ]]; then
                print_info "  Updating symlink to point to new location"
                ln -sf "$SCRIPTS_DEST/$new_target" "$link"
                print_success "  Updated $basename"
            else
                print_warning "  Target script not found in new location"
            fi
        fi
    done < <(find "$HOME/.local/bin" -type l 2>/dev/null)
fi

# List installed script categories
print_info ""
print_info "Installed script categories:"
for dir in "$SCRIPTS_DEST"/*; do
    if [[ -d "$dir" ]]; then
        print_success "$(basename "$dir")"
    fi
done

print_info ""
print_info "Scripts installation complete"
print_info "Scripts are now available in: ~/scripts"