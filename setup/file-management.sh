#!/bin/bash

# File Management Setup Script
# Sets up auto-mounting, file system access, and device management

echo "Setting up file management services..."

# Enable and start udisks2 for automatic mounting
sudo systemctl enable udisks2
sudo systemctl start udisks2

# Enable and start gvfs for virtual file system support
sudo systemctl --global enable gvfs-daemon
sudo systemctl --global start gvfs-daemon

# Ensure user is in storage group for device access
sudo usermod -a -G storage $USER

# Create mount point directory if it doesn't exist
sudo mkdir -p /media/$USER

echo "File management setup complete!"
echo "Note: You may need to log out and back in for group changes to take effect."
echo "USB devices and mobile phones should now auto-mount in /media/$USER/"