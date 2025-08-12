#!/usr/bin/env bash

# Yay AUR Helper Setup Script
set -e

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
    echo -e "  ${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "  ${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    print_info "AUR packages cannot be built as root for security reasons"
    exit 1
fi

print_info "Setting up Yay AUR helper..."

# Check if yay is already installed
if command -v yay >/dev/null 2>&1; then
    print_success "Yay is already installed"
    yay_version=$(yay --version | head -n1)
    print_info "Version: $yay_version"
    exit 0
fi

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    print_error "This script is designed for Arch Linux systems"
    exit 1
fi

print_info "Installing yay from Chaotic AUR repository..."

# Install yay directly from Chaotic AUR
if ! sudo pacman -S --needed --noconfirm yay; then
    print_error "Failed to install yay from Chaotic AUR"
    print_info "Make sure Chaotic AUR repository is properly configured"
    exit 1
fi

print_success "Yay installed successfully!"

# Verify installation
if command -v yay >/dev/null 2>&1; then
    yay_version=$(yay --version | head -n1)
    print_success "Installation verified: $yay_version"
    
    print_info ""
    print_info "Yay is now ready to use!"
    print_info "You can now install AUR packages with: yay -S <package-name>"
    
else
    print_error "Yay installation verification failed"
    exit 1
fi