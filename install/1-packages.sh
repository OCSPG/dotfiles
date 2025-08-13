#!/usr/bin/env bash

# Package installer

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$DOTFILES_DIR/packages"

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    echo "[ERROR] This installer is designed for Arch Linux systems"
    exit 1
fi


# Configure pacman
echo "==> Configuring Pacman"
config_changed=false

# Enable multilib repository if not already enabled
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "  [INFO] Enabling multilib repository..."
    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman\.d\/mirrorlist/ s/^#//' /etc/pacman.conf
    echo "  ✓ Multilib repository enabled"
    config_changed=true
else
    echo "  ✓ Multilib repository already enabled"
fi

# Enable color output if not already enabled
if ! grep -q "^Color" /etc/pacman.conf; then
    echo "  [INFO] Enabling color output..."
    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    echo "  ✓ Color output enabled"
    config_changed=true
else
    echo "  ✓ Color output already enabled"
fi

# Update package databases if config was changed
if [[ "$config_changed" == true ]]; then
    echo "  [INFO] Updating package databases..."
    sudo pacman -Sy
    echo "  ✓ Package databases updated"
fi
echo ""
sleep 1

# Setup Chaotic AUR for pre-built packages
clear
echo "==> Setting up Chaotic AUR"
if ! grep -q "chaotic-aur" /etc/pacman.conf; then
    echo "  [INFO] Adding Chaotic AUR repository..."
    
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
    echo "  ✓ Chaotic AUR repository added"
else
    echo "  ✓ Chaotic AUR already configured"
fi
echo ""
sleep 1

# Setup Yay AUR helper if not installed
clear
if ! command -v yay >/dev/null 2>&1; then
    echo "==> Installing Yay AUR Helper"
    if [[ -f "$PACKAGES_DIR/setup-yay.sh" ]]; then
        if bash "$PACKAGES_DIR/setup-yay.sh"; then
            echo "  ✓ Yay AUR helper installed"
        else
            echo "  ✗ Failed to install Yay AUR helper"
            exit 1
        fi
    else
        echo "  ✗ Yay setup script not found"
        exit 1
    fi
    echo ""
    sleep 1
fi

# Read packages from file, filtering out empty lines and comments
packages=($(grep -v '^#\|^$' "$PACKAGES_DIR/packages.txt"))

if [[ ${#packages[@]} -eq 0 ]]; then
    echo "[ERROR] No packages found in packages.txt"
    exit 1
fi

clear
echo "==> Installing Packages"
echo "  [INFO] Found ${#packages[@]} packages to install"
echo ""
sleep 2

failed_packages=()
installed_count=0

# Install all packages at once
echo "  [INFO] Installing all packages with yay..."
echo ""
sleep 1

if yay -S "${packages[@]}" --noconfirm --needed; then
    echo "  ✓ All packages installed successfully!"
    exit 0
else
    echo "  ✗ Package installation failed!"
    echo "  [INFO] Some packages may have been installed successfully"
    echo "  [INFO] You can retry with: yay -S [package-name]"
    exit 1
fi