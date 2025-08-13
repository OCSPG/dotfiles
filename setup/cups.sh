#!/usr/bin/env bash

# CUPS printing system setup

echo "Printing System Setup"
echo "===================="
echo ""

# Check if CUPS is installed
if ! pacman -Qi cups &> /dev/null; then
    echo "[INFO] Installing CUPS and related packages..."
    yay -S cups cups-pdf system-config-printer --noconfirm --needed
else
    echo "[INFO] CUPS is already installed"
fi

# Enable and start CUPS service
echo "[INFO] Enabling CUPS service..."
sudo systemctl enable cups.service
sudo systemctl start cups.service

# Add user to lp group for printing permissions
echo "[INFO] Adding user to lp group..."
sudo usermod -a -G lp $USER

# Enable network printer discovery
echo "[INFO] Enabling printer discovery service..."
sudo systemctl enable avahi-daemon.service
sudo systemctl start avahi-daemon.service

# Enable CUPS web interface (optional)
echo "[INFO] CUPS web interface is available at http://localhost:631"
echo "      You can manage printers through this interface"

echo ""
echo "[INFO] Printing setup complete!"
echo "[INFO] You may need to log out and back in for group changes to take effect"
echo "[INFO] To add a printer, use system-config-printer or the CUPS web interface"