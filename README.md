# Dotfiles

Personal configuration files and installation system for Arch Linux.

## Quick Start

```bash
git clone https://github.com/OCSPG/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh --all
```

## Components

Installation order (when using `--all`):

1. **packages** - Package lists and modern CLI tools installation
2. **setup** - System setup (seat management, display manager, uwsm)
3. **scripts** - Custom scripts organized by category
4. **config** - Desktop environment configurations (Hyprland, i3, Waybar, etc.)
5. **shell** - Shell configuration files (.zshrc, aliases, plugins)
6. **programs** - User utility programs for ~/.local/bin

## Installation Options

Install all components:
```bash
./install.sh --all
```

Install specific components:
```bash
./install.sh config shell
./install.sh packages
./install.sh etc
```

## Package Management

The installer includes:
- Modern CLI tools (eza, bat, ripgrep, fd, etc.)
- Yay AUR helper installation  
- Complete package lists from the source system
- Automatic dependency resolution
- Seat management for Wayland compositors
- Display manager (ly) and session management (uwsm)

## System Requirements

- Arch Linux
- Git, curl, base-devel (installed automatically)
- Sudo privileges for system configurations

## Structure

```
dotfiles/
├── config/           # ~/.config files
├── shell/            # Shell configurations  
├── programs/         # User programs
├── scripts/          # Custom scripts
├── packages/         # Package management
├── setup/            # System setup scripts
├── install/          # Individual installers (numbered by execution order)
└── install.sh        # Main installer
```

All installers create backups of existing files before making changes.