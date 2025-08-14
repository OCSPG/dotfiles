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
    
    # Allow CUPS printing
    sudo ufw allow 631/tcp comment 'CUPS printing'
 
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

echo ""
echo "[INFO] Network services setup complete!"