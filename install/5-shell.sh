#!/usr/bin/env bash

# Shell configuration installer

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHELL_SRC="$DOTFILES_DIR/shell"
HOME_DEST="$HOME"

# Create backup of existing file
backup_if_exists() {
    local file=$1
    if [[ -e "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  ! Backing up existing $(basename "$file") to $(basename "$backup")"
        mv "$file" "$backup"
    fi
}

# Install shell files
echo "==> Installing shell configuration files..."
echo ""
sleep 1

# Install .zshrc
if [[ -f "$SHELL_SRC/.zshrc" ]]; then
    backup_if_exists "$HOME_DEST/.zshrc"
    if cp "$SHELL_SRC/.zshrc" "$HOME_DEST/"; then
        echo "  ✓ Installed .zshrc"
    else
        echo "  ✗ Failed to install .zshrc"
    fi
else
    echo "  ✗ .zshrc not found in source"
fi

# Install .bashrc
if [[ -f "$SHELL_SRC/.bashrc" ]]; then
    backup_if_exists "$HOME_DEST/.bashrc"
    if cp "$SHELL_SRC/.bashrc" "$HOME_DEST/"; then
        echo "  ✓ Installed .bashrc"
    else
        echo "  ✗ Failed to install .bashrc"
    fi
else
    echo "  ! .bashrc not found in source (optional)"
fi
echo ""
sleep 1

# Check for required ZSH plugins
clear
echo "==> Checking ZSH plugin dependencies..."
echo ""

missing_packages=()

if [[ ! -d "/usr/share/zsh/plugins/zsh-syntax-highlighting" ]]; then
    echo "  ! zsh-syntax-highlighting not installed"
    missing_packages+=("zsh-syntax-highlighting")
else
    echo "  ✓ zsh-syntax-highlighting is installed"
fi

if [[ ! -d "/usr/share/zsh/plugins/zsh-autosuggestions" ]]; then
    echo "  ! zsh-autosuggestions not installed"
    missing_packages+=("zsh-autosuggestions")
else
    echo "  ✓ zsh-autosuggestions is installed"
fi

if command -v zoxide >/dev/null 2>&1; then
    echo "  ✓ zoxide is installed"
else
    echo "  ! zoxide not installed"
    missing_packages+=("zoxide")
fi

if command -v starship >/dev/null 2>&1; then
    echo "  ✓ starship is installed"
else
    echo "  ! starship not installed"
    missing_packages+=("starship")
fi

if [[ ${#missing_packages[@]} -gt 0 ]]; then
    echo ""
    echo "  [INFO] Installing missing dependencies..."
    sleep 1
    if yay -S "${missing_packages[@]}" --noconfirm --needed; then
        echo "  ✓ Dependencies installed successfully"
    else
        echo "  ✗ Failed to install some dependencies"
    fi
fi
echo ""
sleep 2

# Set zsh as default shell if it's not already
clear
echo "==> Setting default shell..."
echo ""
if [[ "$SHELL" != *"zsh" ]]; then
    echo "  [INFO] Setting zsh as default shell..."
    if chsh -s /usr/bin/zsh; then
        echo "  ✓ Default shell changed to zsh"
        echo "  ! Please log out and log back in for changes to take effect"
    else
        echo "  ✗ Failed to change default shell to zsh"
        echo "  [INFO] You can manually change it with: chsh -s /usr/bin/zsh"
    fi
else
    echo "  ✓ zsh is already the default shell"
fi
echo ""
sleep 1

echo "  [INFO] Shell configuration installation complete"