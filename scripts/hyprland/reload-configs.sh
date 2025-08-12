#!/usr/bin/env bash

# Hyprland Config Reload Script
# Reloads all relevant Hyprland ecosystem configurations

set -euo pipefail

echo "🔄 Reloading Hyprland configurations..."

# Reload Hyprland config
echo "  • Hyprland config..."
hyprctl reload

# Restart Waybar
echo "  • Waybar..."
systemctl --user restart waybar.service

# Restart Mako
echo "  • Mako notifications..."
systemctl --user restart mako.service

# Restart Hyprpaper with improved process management
echo "  • Hyprpaper wallpaper..."
if pgrep -x hyprpaper >/dev/null; then
	pkill -x hyprpaper
	# Wait for process to actually terminate
	while pgrep -x hyprpaper >/dev/null; do
		sleep 0.1
	done
fi
hyprpaper >/dev/null 2>&1 &

# Restart Hypridle with improved process management
echo "  • Hypridle idle management..."
if command -v hypridle >/dev/null 2>&1; then
	if pgrep -x hypridle >/dev/null; then
		pkill -x hypridle
		# Wait for process to actually terminate
		while pgrep -x hypridle >/dev/null; do
			sleep 0.1
		done
	fi
	hypridle >/dev/null 2>&1 &
else
	echo "    Warning: hypridle not found in PATH"
fi

# Reload Waypaper
echo "  • Waypaper..."
waypaper --random --fill fill >/dev/null 2>&1
# Fuzzel doesn't need reloading (reads config on launch)

echo "✅ All configurations reloaded!"

# Send notification
notify-send "Configuration Reload" "All Hyprland configs have been reloaded" --urgency normal
