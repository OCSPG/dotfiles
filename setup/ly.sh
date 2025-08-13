#!/usr/bin/env bash

# Ly display manager setup script

echo "[INFO] Setting up ly display manager..."

# Enable ly service
echo "[INFO] Enabling ly service..."
sudo systemctl enable ly.service

echo "[INFO] Ly setup complete!"
echo "[INFO] Reboot to use the ly display manager"