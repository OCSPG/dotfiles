#!/bin/bash

# Disable mouse acceleration by setting flat profile for all pointer devices
# Usage: ./disable-mouse-accel.sh

# Get all pointer device IDs (excluding XTEST devices)
pointer_ids=$(xinput list | grep -E "slave\s+pointer" | grep -v "XTEST" | sed -n 's/.*id=\([0-9]\+\).*/\1/p')

for id in $pointer_ids; do
    # Check if device has libinput acceleration profiles
    if xinput list-props "$id" | grep -q "libinput Accel Profile Enabled"; then
        # Get the number of available profiles
        profiles=$(xinput list-props "$id" | grep "libinput Accel Profiles Available" | sed 's/.*:\s*//' | tr ',' ' ')
        profile_count=$(echo "$profiles" | wc -w)
        
        # Create the flat profile setting based on profile count
        if [ "$profile_count" -eq 2 ]; then
            # Two profiles: adaptive, flat
            xinput set-prop "$id" "libinput Accel Profile Enabled" 0, 1
        elif [ "$profile_count" -eq 3 ]; then
            # Three profiles: adaptive, flat, custom
            xinput set-prop "$id" "libinput Accel Profile Enabled" 0, 1, 0
        fi
        
        device_name=$(xinput list --name-only "$id")
        echo "Disabled acceleration for: $device_name (ID: $id)"
    fi
done