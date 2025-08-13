#!/usr/bin/env bash

# Yay AUR Helper Setup Script

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "  [ERROR] This script should not be run as root"
    echo "  [INFO] AUR packages cannot be built as root for security reasons"
    exit 1
fi

echo "  [INFO] Setting up Yay AUR helper..."

# Check if yay is already installed
if command -v yay >/dev/null 2>&1; then
    echo "  ✓ Yay is already installed"
    yay_version=$(yay --version | head -n1)
    echo "  [INFO] Version: $yay_version"
    exit 0
fi

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    echo "  [ERROR] This script is designed for Arch Linux systems"
    exit 1
fi

echo "  [INFO] Installing yay from Chaotic AUR repository..."
sleep 1

# Install yay directly from Chaotic AUR
if ! sudo pacman -S --needed --noconfirm yay; then
    echo "  [ERROR] Failed to install yay from Chaotic AUR"
    echo "  [INFO] Make sure Chaotic AUR repository is properly configured"
    exit 1
fi

echo "  ✓ Yay installed successfully!"

# Verify installation
if command -v yay >/dev/null 2>&1; then
    yay_version=$(yay --version | head -n1)
    echo "  ✓ Installation verified: $yay_version"
    echo ""
    echo "  [INFO] Yay is now ready to use!"
    echo "  [INFO] You can now install AUR packages with: yay -S <package-name>"
else
    echo "  [ERROR] Yay installation verification failed"
    exit 1
fi