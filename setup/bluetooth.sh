#!/usr/bin/env bash

# Bluetooth setup script

echo "Bluetooth Setup"
echo "==============="
echo ""

# Check if bluetooth packages are installed
packages_needed=()
if ! pacman -Qi bluez &> /dev/null; then
    packages_needed+=("bluez")
fi
if ! pacman -Qi bluez-utils &> /dev/null; then
    packages_needed+=("bluez-utils")
fi
if ! pacman -Qi blueman &> /dev/null; then
    packages_needed+=("blueman")
fi

if [[ ${#packages_needed[@]} -gt 0 ]]; then
    echo "[INFO] Installing bluetooth packages..."
    yay -S "${packages_needed[@]}" --noconfirm --needed
else
    echo "[INFO] Bluetooth packages already installed"
fi

# Enable and start bluetooth service
echo "[INFO] Enabling bluetooth service..."
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Add user to lp group for bluetooth access
echo "[INFO] Adding user to lp group..."
sudo usermod -a -G lp $USER

# Enable auto power-on for bluetooth
echo "[INFO] Configuring bluetooth to auto power-on..."
sudo sed -i 's/#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf 2>/dev/null || \
    echo "AutoEnable=true" | sudo tee -a /etc/bluetooth/main.conf > /dev/null

echo ""
echo "[INFO] Bluetooth setup complete!"
echo "[INFO] You can manage bluetooth devices using blueman-applet or bluetoothctl"
echo "[INFO] You may need to log out and back in for group changes to take effect"