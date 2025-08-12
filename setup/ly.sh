#!/usr/bin/env bash

# ly Display Manager Setup Script
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

# Function to prompt for yes/no
confirm() {
    local prompt=$1
    local default=${2:-n}
    
    # Check if running in non-interactive mode
    if [[ ! -t 0 ]]; then
        print_info "$prompt (auto-choosing: $default)"
        [[ "$default" == "y" ]] && return 0 || return 1
    fi
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi
    
    read -p "$prompt" -n 1 -r
    echo ""
    
    if [[ "$default" == "y" ]]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1 || return 0
    else
        [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
    fi
}

# Check if ly is installed
if ! pacman -Q ly >/dev/null 2>&1; then
    print_error "ly display manager is not installed"
    print_info "Please install ly first: sudo pacman -S ly"
    exit 1
fi

print_step "ly Display Manager Setup"
print_info "This will configure ly as the default display manager"
print_warning "This will disable other display managers (gdm, sddm, lightdm, etc.)"
echo ""

if confirm "Configure ly as the default display manager?" y; then
    print_info "Configuring ly display manager..."
    
    # Disable other display managers
    print_info "Disabling other display managers..."
    for dm in gdm sddm lightdm lxdm xdm; do
        if systemctl is-enabled "${dm}.service" >/dev/null 2>&1; then
            print_info "Disabling $dm..."
            sudo systemctl disable "${dm}.service" || true
        fi
    done
    
    # Enable ly
    print_info "Enabling ly display manager..."
    if sudo systemctl enable ly.service; then
        print_success "ly.service enabled"
    else
        print_error "Failed to enable ly.service"
        exit 1
    fi
    
    # Check if ly is already running
    if systemctl is-active ly.service >/dev/null 2>&1; then
        print_info "ly.service is already running"
    else
        print_info "ly.service will start on next boot"
    fi
    
    echo ""
    print_success "ly display manager setup completed!"
    print_info ""
    print_info "Configuration details:"
    print_info "• ly will start automatically on boot"
    print_info "• Other display managers have been disabled"
    print_info "• ly provides a minimal TUI login interface"
    print_info ""
    print_info "To start ly now (optional): sudo systemctl start ly.service"
    print_warning "Starting ly now will switch to the login screen immediately"
    
    if confirm "Start ly display manager now?" n; then
        print_info "Starting ly display manager..."
        sudo systemctl start ly.service
    else
        print_info "ly will start on next reboot"
    fi
else
    print_info "Skipping ly setup"
fi

print_success "ly setup script completed!"