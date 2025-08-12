#!/usr/bin/env bash

# Ly display manager setup script
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info "Setting up ly display manager..."

# Enable ly service
print_info "Enabling ly service..."
sudo systemctl enable ly.service

print_info "Ly setup complete!"
print_info "Reboot to use the ly display manager"