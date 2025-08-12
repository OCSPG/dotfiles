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

print_info "Installing prerequisites for building AUR packages..."

# Install base-devel and git if not already present
if ! sudo pacman -S --needed --noconfirm git base-devel; then
    print_error "Failed to install prerequisites"
    exit 1
fi

print_success "Prerequisites installed"

# Create temporary directory for building yay
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

print_info "Cloning yay repository..."
cd "$TEMP_DIR"

if ! git clone https://aur.archlinux.org/yay.git; then
    print_error "Failed to clone yay repository"
    exit 1
fi

cd yay

print_info "Building and installing yay..."
print_warning "This may take a few minutes..."

# Build and install yay
if makepkg -si --noconfirm; then
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
    
else
    print_error "Failed to build and install yay"
    exit 1
fi