#!/usr/bin/env bash

# Dotfiles installer - Main wrapper script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$DOTFILES_DIR/install"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install it first:"
        echo "  sudo pacman -S git"
        echo "  # or"
        echo "  yay -S git"
        exit 1
    fi
    
    # Check if we're in a git repository (optional warning)
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        print_success "Running from git repository"
    else
        print_warning "Not running from a git repository"
    fi
    
    print_success "Prerequisites check passed"
}

# Function to get available components
get_available_components() {
    local components=()
    for script in "$INSTALL_DIR"/*.sh; do
        [[ -f "$script" ]] || continue
        local component=$(basename "$script" .sh)
        components+=("$component")
    done
    printf '%s\n' "${components[@]}" | sort
}

# Function to display usage
usage() {
    local available_components=($(get_available_components))
    
    echo "Usage: $0 [options] [component1] [component2] ..."
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -a, --all      Install all components"
    echo "  --dry-run      Show what would be installed without making changes"
    echo ""
    echo "Available Components:"
    for component in "${available_components[@]}"; do
        echo "  $component"
    done
    echo ""
    echo "Examples:"
    echo "  $0 --all                    # Install everything"
    echo "  $0 config shell             # Install only config and shell"
    echo "  $0 ${available_components[0]}                      # Install only ${available_components[0]}"
}

# Function to run an installer script
run_installer() {
    local component=$1
    local script="$INSTALL_DIR/${component}.sh"
    
    # Handle numbered scripts - look for either numbered or unnumbered version
    if [[ ! -f "$script" ]]; then
        # Try to find numbered version
        local numbered_script=$(find "$INSTALL_DIR" -name "*-${component}.sh" | head -1)
        if [[ -f "$numbered_script" ]]; then
            script="$numbered_script"
        fi
    fi
    
    # Skip dangerous system-wide installers for safety
    if [[ "$component" == "etc" ]]; then
        print_warning "Skipping $component installer (system-wide changes disabled for safety)"
        print_info "To install system configs manually: sudo bash $script"
        return 0
    fi
    
    if [[ ! -f "$script" ]]; then
        print_error "Installer script for '$component' not found: $script"
        return 1
    fi
    
    print_info "Installing $component..."
    if bash "$script"; then
        print_success "$component installed successfully"
    else
        print_error "Failed to install $component"
        return 1
    fi
}

# Parse command line arguments
COMPONENTS=()
INSTALL_ALL=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -a|--all)
            INSTALL_ALL=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            COMPONENTS+=("$1")
            shift
            ;;
    esac
done

# If no components specified and not --all, show usage
if [[ ${#COMPONENTS[@]} -eq 0 ]] && [[ "$INSTALL_ALL" == false ]]; then
    usage
    exit 1
fi

# If --all specified, install all components
if [[ "$INSTALL_ALL" == true ]]; then
    COMPONENTS=($(get_available_components))
fi

# Main installation
echo "======================================"
echo "      Dotfiles Installation"
echo "======================================"
echo ""
print_info "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Check prerequisites first
check_prerequisites
echo ""

# Confirm installation
echo "Components to install:"
for component in "${COMPONENTS[@]}"; do
    echo "  - $component"
done
echo ""

# Check if running in non-interactive mode (e.g., piped input)
if [[ ! -t 0 ]]; then
    print_info "Running in non-interactive mode, proceeding with installation..."
else
    read -p "Continue with installation? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Installation cancelled"
        exit 0
    fi
fi

# Run installers
failed_components=()
successful_components=()

for component in "${COMPONENTS[@]}"; do
    if run_installer "$component"; then
        successful_components+=("$component")
    else
        failed_components+=("$component")
    fi
done

echo ""
echo "======================================"
print_info "Installation Summary"
echo "======================================"

if [[ ${#successful_components[@]} -gt 0 ]]; then
    print_success "Successfully installed components:"
    for component in "${successful_components[@]}"; do
        echo "  ✓ $component"
    done
fi

if [[ ${#failed_components[@]} -gt 0 ]]; then
    echo ""
    print_error "Failed to install components:"
    for component in "${failed_components[@]}"; do
        echo "  ✗ $component"
    done
    echo ""
    print_warning "You can retry failed components individually:"
    for component in "${failed_components[@]}"; do
        echo "  ./install.sh $component"
    done
    echo ""
    print_error "Installation completed with errors"
    exit 1
else
    print_success "All components installed successfully!"
fi