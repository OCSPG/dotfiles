#!/usr/bin/env bash

# Audio system setup

echo "Audio System Setup"
echo "=================="
echo ""

# Check if pipewire is installed (modern audio system)
if pacman -Qi pipewire &> /dev/null; then
    echo "[INFO] PipeWire audio system detected"
    
    # Enable pipewire services
    echo "[INFO] Enabling PipeWire services..."
    systemctl --user enable pipewire.service
    systemctl --user enable pipewire-pulse.service
    systemctl --user enable wireplumber.service
    
    systemctl --user start pipewire.service
    systemctl --user start pipewire-pulse.service
    systemctl --user start wireplumber.service
    
    # Install additional pipewire packages if needed
    packages_needed=()
    if ! pacman -Qi pipewire-alsa &> /dev/null; then
        packages_needed+=("pipewire-alsa")
    fi
    if ! pacman -Qi pipewire-jack &> /dev/null; then
        packages_needed+=("pipewire-jack")
    fi
    if ! pacman -Qi pipewire-pulse &> /dev/null; then
        packages_needed+=("pipewire-pulse")
    fi
    
    if [[ ${#packages_needed[@]} -gt 0 ]]; then
        echo "[INFO] Installing additional PipeWire packages..."
        yay -S "${packages_needed[@]}" --noconfirm --needed
    fi
    
else
    echo "[INFO] PipeWire not detected, installing..."
    yay -S pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber --noconfirm --needed
    
    echo "[INFO] Enabling PipeWire services..."
    systemctl --user enable pipewire.service
    systemctl --user enable pipewire-pulse.service
    systemctl --user enable wireplumber.service
fi

# Add user to audio group
echo "[INFO] Adding user to audio group..."
sudo usermod -a -G audio $USER

# Install audio control tools if not present
if ! pacman -Qi pwvucontrol &> /dev/null; then
    echo "[INFO] Installing pwvucontrol for audio management..."
    yay -S pwvucontrol --noconfirm --needed
fi

# Enable real-time scheduling for audio (reduces latency)
if ! grep -q "@audio" /etc/security/limits.conf 2>/dev/null; then
    echo "[INFO] Configuring real-time audio priorities..."
    echo "@audio   -  rtprio     95" | sudo tee -a /etc/security/limits.conf > /dev/null
    echo "@audio   -  memlock    unlimited" | sudo tee -a /etc/security/limits.conf > /dev/null
fi

echo ""
echo "[INFO] Audio setup complete!"
echo "[INFO] Use pavucontrol to manage audio devices and volumes"
echo "[INFO] You may need to log out and back in for group changes to take effect"