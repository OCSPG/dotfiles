#!/usr/bin/env bash

# Get the directory of this script
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$DOTFILES_DIR/install"

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
    
    if [[ ! -f "$script" ]]; then
        echo "[ERROR] Installer script for '$component' not found: $script"
        return 1
    fi
    
    echo "[INFO] Installing $component..."
    if bash "$script"; then
        echo "[SUCCESS] $component installed successfully"
    else
        echo "[ERROR] Failed to install $component"
        return 1
    fi
}

# Main installation
echo "======================================"
echo "      Dotfiles Installation"
echo "======================================"
echo ""
echo "[INFO] Dotfiles directory: $DOTFILES_DIR"
echo ""

# Get available components
available_components=($(get_available_components))

echo "Choose installation mode:"
echo "  1) Auto - Install all components"
echo "  2) Select - Choose specific components"
echo "  3) Exit"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "[INFO] Installing all components..."
        echo ""
        COMPONENTS=("${available_components[@]}")
        ;;
    2)
        echo ""
        echo "Available components:"
        for i in "${!available_components[@]}"; do
            echo "  $((i+1))) ${available_components[$i]}"
        done
        echo ""
        echo "Enter component numbers to install (space-separated, e.g., '1 3 5')"
        echo "Or press Enter to install all:"
        read -p "> " selections
        
        if [[ -z "$selections" ]]; then
            COMPONENTS=("${available_components[@]}")
        else
            COMPONENTS=()
            for num in $selections; do
                index=$((num-1))
                if [[ $index -ge 0 && $index -lt ${#available_components[@]} ]]; then
                    COMPONENTS+=("${available_components[$index]}")
                else
                    echo "[WARNING] Invalid selection: $num"
                fi
            done
        fi
        ;;
    3)
        echo "[INFO] Installation cancelled"
        exit 0
        ;;
    *)
        echo "[ERROR] Invalid choice"
        exit 1
        ;;
esac

# Confirm installation
echo ""
echo "Components to install:"
for component in "${COMPONENTS[@]}"; do
    echo "  - $component"
done
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "[INFO] Installation cancelled"
    exit 0
fi

# Run installers
failed_components=()
successful_components=()

for component in "${COMPONENTS[@]}"; do
    clear
    echo "======================================"
    echo "Installing: $component"
    echo "======================================"
    echo ""
    sleep 1
    if run_installer "$component"; then
        successful_components+=("$component")
    else
        failed_components+=("$component")
    fi
    sleep 2
done

clear
echo ""
echo "======================================"
echo "[INFO] Installation Summary"
echo "======================================"

if [[ ${#successful_components[@]} -gt 0 ]]; then
    echo "[SUCCESS] Successfully installed components:"
    for component in "${successful_components[@]}"; do
        echo "  ✓ $component"
    done
fi

if [[ ${#failed_components[@]} -gt 0 ]]; then
    echo ""
    echo "[ERROR] Failed to install components:"
    for component in "${failed_components[@]}"; do
        echo "  ✗ $component"
    done
    echo ""
    echo "[WARNING] You can retry failed components individually by running this script again"
    echo ""
    echo "[ERROR] Installation completed with errors"
    exit 1
else
    echo "[SUCCESS] All components installed successfully!"
fi