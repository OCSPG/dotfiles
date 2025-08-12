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

# Restart Polybar if running
echo "  • Polybar..."
if pgrep -x polybar >/dev/null; then
	pkill -x polybar
	while pgrep -x polybar >/dev/null; do
		sleep 0.1
	done
	polybar >/dev/null 2>&1 &
fi

# Restart Walker if running
echo "  • Walker..."
if pgrep -x walker >/dev/null; then
	pkill -x walker
	while pgrep -x walker >/dev/null; do
		sleep 0.1
	done
fi

# Restart EWW if running
echo "  • EWW widgets..."
if pgrep -x eww >/dev/null; then
	eww reload >/dev/null 2>&1 || true
fi

# Restart Cliphist service if running
echo "  • Cliphist clipboard history..."
if pgrep -x cliphist >/dev/null; then
	pkill -x cliphist
	while pgrep -x cliphist >/dev/null; do
		sleep 0.1
	done
	cliphist >/dev/null 2>&1 &
fi

# Reload Waypaper
echo "  • Waypaper..."
if command -v waypaper >/dev/null 2>&1; then
	waypaper --random --fill fill >/dev/null 2>&1
fi

# Note: Fuzzel, Rofi, Walker don't need reloading (read config on launch)

echo "✅ All configurations reloaded!"

# Send notification
notify-send "Configuration Reload" "All Hyprland configs have been reloaded" --urgency normal
