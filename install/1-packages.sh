#!/usr/bin/env bash

# Package installer
set -e

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

# Function to prompt for yes/no
confirm() {
    local prompt=$1
    local default=${2:-n}
    
    # Check if running in non-interactive mode (e.g., piped input)
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

# Check if we're on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    print_error "This installer is designed for Arch Linux systems"
    exit 1
fi

print_info "Package Installation"
print_info "==================="
print_warning "This will install packages from the consolidated package list"
print_info "Total packages: $(grep -v '^#\|^$' "$PACKAGES_DIR/packages.txt" | wc -l)"
echo ""

# Step 1: CachyOS Repository Setup (DISABLED for safety)
print_step "Step 1: CachyOS Repository Setup"
print_info "CachyOS repository setup disabled for clean system compatibility"
print_info "Using standard Arch Linux repositories only"

echo ""

# Step 2: Setup Yay AUR helper
print_step "Step 2: Yay AUR Helper Setup"
if ! command -v yay >/dev/null 2>&1; then
    print_info "Yay AUR helper not found, installing..."
    if [[ -f "$PACKAGES_DIR/setup-yay.sh" ]]; then
        if bash "$PACKAGES_DIR/setup-yay.sh"; then
            print_success "Yay AUR helper installed"
        else
            print_error "Failed to install Yay AUR helper"
            print_warning "AUR packages will be skipped"
        fi
    else
        print_error "Yay setup script not found"
    fi
else
    print_success "Yay AUR helper is already installed"
fi

echo ""

# Step 3: Install all packages
print_step "Step 3: Package Installation"
if [[ -f "$PACKAGES_DIR/packages.txt" ]]; then
    package_count=$(grep -v '^#\|^$' "$PACKAGES_DIR/packages.txt" | wc -l)
    print_info "Found $package_count packages to install"
    
    if confirm "Install all packages?" y; then
        print_info "Installing packages..."
        print_warning "This may take several minutes depending on package count"
        
        failed_packages=()
        aur_packages=()
        official_packages=()
        installed_count=0
        
        # Separate AUR packages from official packages
        while IFS= read -r package; do
            [[ -z "$package" || "$package" =~ ^# ]] && continue
            
            # Check if package exists in official repos
            if pacman -Si "$package" &>/dev/null; then
                official_packages+=("$package")
            else
                aur_packages+=("$package")
            fi
        done < "$PACKAGES_DIR/packages.txt"
        
        print_info "Found ${#official_packages[@]} official packages and ${#aur_packages[@]} AUR packages"
        
        # Install official packages first
        if [[ ${#official_packages[@]} -gt 0 ]]; then
            print_info "Installing official packages..."
            
            # Try batch installation first
            temp_packages=$(mktemp)
            printf '%s\n' "${official_packages[@]}" > "$temp_packages"
            
            if sudo pacman -S --needed --noconfirm - < "$temp_packages"; then
                installed_count=${#official_packages[@]}
                print_success "Successfully installed ${#official_packages[@]} official packages"
            else
                print_warning "Batch installation failed, trying individual packages..."
                
                for package in "${official_packages[@]}"; do
                    print_info "Installing: $package"
                    if sudo pacman -S --needed --noconfirm "$package"; then
                        ((installed_count++))
                        print_success "Installed: $package"
                    else
                        failed_packages+=("$package")
                        print_error "Failed: $package"
                    fi
                done
            fi
            rm -f "$temp_packages"
        fi
        
        # Install AUR packages
        if [[ ${#aur_packages[@]} -gt 0 ]]; then
            if command -v yay >/dev/null 2>&1; then
                print_info "Installing AUR packages..."
                print_warning "This may take a very long time as packages are built from source"
                
                for package in "${aur_packages[@]}"; do
                    print_info "Installing AUR package: $package"
                    if yay -S --needed --noconfirm "$package"; then
                        ((installed_count++))
                        print_success "Installed: $package"
                    else
                        failed_packages+=("$package")
                        print_error "Failed: $package"
                    fi
                done
            else
                print_warning "Yay not available, skipping ${#aur_packages[@]} AUR packages"
                for package in "${aur_packages[@]}"; do
                    failed_packages+=("$package (AUR - yay not available)")
                done
            fi
        fi
        
        echo ""
        print_success "Installed $installed_count packages"
        
        if [[ ${#failed_packages[@]} -gt 0 ]]; then
            print_warning "Failed to install ${#failed_packages[@]} packages:"
            for pkg in "${failed_packages[@]}"; do
                print_warning "  - $pkg"
            done
            
            print_info "To retry failed packages manually:"
            print_info "  sudo pacman -S [package-name]  # for official packages"
            print_info "  yay -S [package-name]          # for AUR packages"
        fi
    else
        print_info "Skipping package installation"
    fi
else
    print_error "Package list not found: $PACKAGES_DIR/packages.txt"
    exit 1
fi

echo ""

# Final summary
print_info "Package Installation Summary"
print_info "============================"
print_success "Package installation process completed"

if [[ ${#failed_packages[@]} -gt 0 ]] || [[ ${#failed_aur[@]} -gt 0 ]]; then
    print_warning "Some packages failed to install - review the warnings above"
    print_info "You can manually install failed packages later"
fi

print_info ""
print_info "Post-installation recommendations:"
print_info "1. Reboot the system to ensure all services start properly"
print_info "2. Update package databases: sudo pacman -Sy"
print_info "3. Check for orphaned packages: pacman -Qdt"

print_success "Package installation complete!"