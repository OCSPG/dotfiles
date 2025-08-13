#!/usr/bin/env bash

# Network services setup

echo "Network Services Setup"
echo "====================="
echo ""

# Enable firewall (if installed)
if pacman -Qi ufw &> /dev/null; then
    echo "[INFO] Configuring UFW firewall..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # Allow common services
    echo "[INFO] Allowing common services through firewall..."
    
    # Allow mDNS for local network discovery (Avahi)
    sudo ufw allow 5353/udp comment 'mDNS/Avahi'
    
    # Allow CUPS printing
    sudo ufw allow 631/tcp comment 'CUPS printing'
    
    # Allow KDE Connect if it's installed
    if pacman -Qi kdeconnect &> /dev/null; then
        sudo ufw allow 1714:1764/tcp comment 'KDE Connect'
        sudo ufw allow 1714:1764/udp comment 'KDE Connect'
    fi
    
    # Allow Syncthing if it's installed
    if pacman -Qi syncthing &> /dev/null; then
        sudo ufw allow 22000/tcp comment 'Syncthing'
        sudo ufw allow 21027/udp comment 'Syncthing discovery'
    fi
    
    sudo ufw --force enable
    sudo systemctl enable ufw.service
else
    echo "[INFO] UFW not installed, skipping firewall setup"
    echo "      To install: yay -S ufw"
fi

# Enable SSH daemon (optional)
read -p "Enable SSH server? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! pacman -Qi openssh &> /dev/null; then
        echo "[INFO] Installing OpenSSH..."
        yay -S openssh --noconfirm --needed
    fi
    echo "[INFO] Enabling SSH daemon..."
    sudo systemctl enable sshd.service
    sudo systemctl start sshd.service
    
    # Allow SSH through firewall if UFW is active
    if pacman -Qi ufw &> /dev/null && sudo ufw status | grep -q "Status: active"; then
        echo "[INFO] Allowing SSH through firewall..."
        sudo ufw allow 22/tcp comment 'SSH'
    fi
    
    echo "[INFO] SSH is now running on port 22"
else
    echo "[INFO] Skipping SSH setup"
fi

# Enable mDNS/Avahi for local network discovery
if pacman -Qi avahi &> /dev/null; then
    echo "[INFO] Enabling Avahi for local network discovery..."
    sudo systemctl enable avahi-daemon.service
    sudo systemctl start avahi-daemon.service
else
    echo "[INFO] Avahi not installed, skipping mDNS setup"
fi

echo ""
echo "[INFO] Network services setup complete!"