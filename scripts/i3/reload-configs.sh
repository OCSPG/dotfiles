#!/usr/bin/env bash

# i3 Config Reload Script
# Reloads all relevant i3 ecosystem configurations

set -euo pipefail

echo "🔄 Reloading i3 configurations..."

# Reload i3 config
echo "  • i3 window manager..."
i3-msg reload

# Restart Polybar if running (separate from i3bar)
echo "  • Polybar..."
if pgrep -x polybar >/dev/null; then
	pkill -x polybar
	while pgrep -x polybar >/dev/null; do
		sleep 0.1
	done
	polybar >/dev/null 2>&1 &
fi

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

# Set wallpaper (try both nitrogen and waypaper)
echo "  • Setting wallpaper..."
if command -v nitrogen >/dev/null 2>&1; then
	nitrogen --restore >/dev/null 2>&1
elif command -v waypaper >/dev/null 2>&1; then
	waypaper --random --fill fill >/dev/null 2>&1
fi

echo "✅ All configurations reloaded!"

# Send notification
notify-send "Configuration Reload" "All i3 configs have been reloaded" --urgency normal