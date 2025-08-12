#!/bin/bash

# Power Management Setup Script
# Optionally installs and configures TLP for laptop power optimization

echo "Power Management Setup"
echo "====================="
echo "This script can install TLP for laptop battery optimization."
echo "TLP is recommended for laptops but not needed for desktop systems."
echo ""

read -p "Is this a laptop? Install TLP for power management? (y/N): " install_tlp

if [[ $install_tlp =~ ^[Yy]$ ]]; then
    echo "Installing TLP..."
    yay -S tlp tlp-rdw --noconfirm
    
    echo "Enabling TLP service..."
    sudo systemctl enable tlp.service
    sudo systemctl start tlp.service
    
    echo "Masking conflicting services..."
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
    
    echo "TLP has been installed and configured."
    echo "You can check TLP status with: sudo tlp-stat"
    echo "Configuration file: /etc/tlp.conf"
else
    echo "Skipping TLP installation."
fi

echo "Power management setup complete!"