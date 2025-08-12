#!/usr/bin/env bash

# Shell configuration installer
set -e

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHELL_SRC="$DOTFILES_DIR/shell"
HOME_DEST="$HOME"

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

# Install shell files
print_info "Installing shell configuration files..."

# Install .zshrc
if [[ -f "$SHELL_SRC/.zshrc" ]]; then
    backup_if_exists "$HOME_DEST/.zshrc"
    if cp "$SHELL_SRC/.zshrc" "$HOME_DEST/"; then
        print_success "Installed .zshrc"
    else
        print_error "Failed to install .zshrc"
    fi
else
    print_error ".zshrc not found in source"
fi

# Install .bashrc
if [[ -f "$SHELL_SRC/.bashrc" ]]; then
    backup_if_exists "$HOME_DEST/.bashrc"
    if cp "$SHELL_SRC/.bashrc" "$HOME_DEST/"; then
        print_success "Installed .bashrc"
    else
        print_error "Failed to install .bashrc"
    fi
else
    print_warning ".bashrc not found in source (optional)"
fi

# Check for required ZSH plugins
print_info "Checking ZSH plugin dependencies..."

plugins_needed=false
if [[ ! -d "/usr/share/zsh/plugins/zsh-syntax-highlighting" ]]; then
    print_warning "zsh-syntax-highlighting not installed"
    plugins_needed=true
fi

if [[ ! -d "/usr/share/zsh/plugins/zsh-autosuggestions" ]]; then
    print_warning "zsh-autosuggestions not installed"
    plugins_needed=true
fi

if command -v zoxide >/dev/null 2>&1; then
    print_success "zoxide is installed"
else
    print_warning "zoxide not installed"
    plugins_needed=true
fi

if command -v starship >/dev/null 2>&1; then
    print_success "starship is installed"
else
    print_warning "starship not installed"
    plugins_needed=true
fi

if [[ "$plugins_needed" == true ]]; then
    print_info ""
    print_info "To install missing dependencies, run:"
    print_info "  yay -S zsh-syntax-highlighting zsh-autosuggestions zoxide starship --noconfirm"
fi

# Set zsh as default shell if it's not already
if [[ "$SHELL" != *"zsh" ]]; then
    print_info "Setting zsh as default shell..."
    if chsh -s /usr/bin/zsh; then
        print_success "Default shell changed to zsh"
        print_warning "Please log out and log back in for changes to take effect"
    else
        print_error "Failed to change default shell to zsh"
        print_info "You can manually change it with: chsh -s /usr/bin/zsh"
    fi
else
    print_success "zsh is already the default shell"
fi

print_info "Shell configuration installation complete"