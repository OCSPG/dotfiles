#!/usr/bin/env bash

# Scripts folder installer

# Get the directory of the main dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_SRC="$DOTFILES_DIR/scripts"
SCRIPTS_DEST="$HOME/scripts"

# Install scripts
echo "==> Installing scripts to ~/scripts..."
echo ""
sleep 1

# Check if scripts directory already exists
if [[ -d "$SCRIPTS_DEST" ]]; then
    echo "  ! ~/scripts already exists"
    
    # Check if it's a symlink
    if [[ -L "$SCRIPTS_DEST" ]]; then
        echo "  [INFO] ~/scripts is a symlink to: $(readlink "$SCRIPTS_DEST")"
    fi
    
    # Create backup
    backup_dir="${SCRIPTS_DEST}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "  ! Backing up existing scripts to $(basename "$backup_dir")"
    mv "$SCRIPTS_DEST" "$backup_dir"
fi

# Copy scripts directory
if cp -r "$SCRIPTS_SRC" "$SCRIPTS_DEST"; then
    echo "  ✓ Copied scripts directory"
else
    echo "  ✗ Failed to copy scripts directory"
    exit 1
fi

# Make all .sh files executable
echo "  [INFO] Making shell scripts executable..."
find "$SCRIPTS_DEST" -type f -name "*.sh" -exec chmod +x {} \;
echo "  ✓ Made all .sh files executable"
echo ""
sleep 1

# Check for symlinks in .local/bin that point to old Scripts location
clear
echo "==> Checking for existing symlinks in ~/.local/bin..."
echo ""
if [[ -d "$HOME/.local/bin" ]]; then
    while IFS= read -r link; do
        target=$(readlink "$link")
        if [[ "$target" == *"/Scripts/"* ]] || [[ "$target" == *"/scripts/"* ]]; then
            basename=$(basename "$link")
            echo "  ! Found symlink: $basename -> $target"
            
            # Check if the script exists in new location
            new_target="$SCRIPTS_DEST/${target##*/Scripts/}"
            new_target="${new_target##*/scripts/}"
            
            if [[ -f "$SCRIPTS_DEST/$new_target" ]]; then
                echo "    [INFO] Updating symlink to point to new location"
                ln -sf "$SCRIPTS_DEST/$new_target" "$link"
                echo "    ✓ Updated $basename"
            else
                echo "    ! Target script not found in new location"
            fi
        fi
    done < <(find "$HOME/.local/bin" -type l 2>/dev/null)
fi
echo ""
sleep 1

# List installed script categories
clear
echo "==> Installed script categories:"
echo ""
for dir in "$SCRIPTS_DEST"/*; do
    if [[ -d "$dir" ]]; then
        echo "  ✓ $(basename "$dir")"
    fi
done
echo ""
echo "  [INFO] Scripts installation complete"
echo "  [INFO] Scripts are now available in: ~/scripts"