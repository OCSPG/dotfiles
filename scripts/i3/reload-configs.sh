#!/usr/bin/env bash

# i3 Config Reload Script
# Reloads all relevant i3 ecosystem configurations

set -euo pipefail

echo "🔄 Reloading i3 configurations..."

# Reload i3 config
echo "  • i3 window manager..."
i3-msg reload

# i3bar is handled by i3 reload automatically

# Restart Dunst notifications with improved process management
echo "  • Dunst notifications..."
if pgrep -x dunst >/dev/null; then
	pkill -x dunst
	# Wait for process to actually terminate
	while pgrep -x dunst >/dev/null; do
		sleep 0.1
	done
fi
dunst >/dev/null 2>&1 &

# Set wallpaper
echo "  • Setting wallpaper..."
nitrogen --restore >/dev/null 2>&1

echo "✅ All configurations reloaded!"

# Send notification
notify-send "Configuration Reload" "All i3 configs have been reloaded" --urgency normal