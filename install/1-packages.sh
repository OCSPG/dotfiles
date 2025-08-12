#!/usr/bin/env bash

# Package installer

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$DOTFILES_DIR/packages"

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

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    print_error "This installer is designed for Arch Linux systems"
    exit 1
fi


# Configure pacman
print_step "Configuring Pacman"
config_changed=false

# Enable multilib repository if not already enabled
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    print_info "Enabling multilib repository..."
    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman\.d\/mirrorlist/ s/^#//' /etc/pacman.conf
    print_success "Multilib repository enabled"
    config_changed=true
else
    print_success "Multilib repository already enabled"
fi

# Enable color output if not already enabled
if ! grep -q "^Color" /etc/pacman.conf; then
    print_info "Enabling color output..."
    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    print_success "Color output enabled"
    config_changed=true
else
    print_success "Color output already enabled"
fi

# Update package databases if config was changed
if [[ "$config_changed" == true ]]; then
    print_info "Updating package databases..."
    sudo pacman -Sy
    print_success "Package databases updated"
fi
echo ""

# Setup Chaotic AUR for pre-built packages
print_step "Setting up Chaotic AUR"
if ! grep -q "chaotic-aur" /etc/pacman.conf; then
    print_info "Adding Chaotic AUR repository..."
    
    # Import GPG key
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    
    # Install keyring and mirrorlist packages
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
    
    # Add Chaotic AUR to pacman.conf
    echo "" | sudo tee -a /etc/pacman.conf
    echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    
    # Update package databases
    sudo pacman -Sy
    print_success "Chaotic AUR repository added"
else
    print_success "Chaotic AUR already configured"
fi
echo ""

# Setup Yay AUR helper if not installed
if ! command -v yay >/dev/null 2>&1; then
    print_step "Installing Yay AUR Helper"
    if [[ -f "$PACKAGES_DIR/setup-yay.sh" ]]; then
        if bash "$PACKAGES_DIR/setup-yay.sh"; then
            print_success "Yay AUR helper installed"
        else
            print_error "Failed to install Yay AUR helper"
            exit 1
        fi
    else
        print_error "Yay setup script not found"
        exit 1
    fi
    echo ""
fi

# Read packages from file, filtering out empty lines and comments
packages=($(grep -v '^#\|^$' "$PACKAGES_DIR/packages.txt"))

if [[ ${#packages[@]} -eq 0 ]]; then
    print_error "No packages found in packages.txt"
    exit 1
fi

print_step "Installing Packages"
print_info "Found ${#packages[@]} packages to install"
echo ""

failed_packages=()
installed_count=0

# Install all packages at once
print_info "Installing all packages with yay..."
echo ""

if yay -S "${packages[@]}" --noconfirm --needed; then
    print_success "All packages installed successfully!"
    exit 0
else
    print_error "Package installation failed!"
    print_info "Some packages may have been installed successfully"
    print_info "You can retry with: yay -S [package-name]"
    exit 1
fi