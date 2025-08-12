#!/bin/bash
# Toggle CM106 digital input to E30 output links

set -euo pipefail

# Define connection endpoints
readonly CM106_L="alsa_input.usb-0d8c_USB_Sound_Device-00.iec958-stereo:capture_FL"
readonly CM106_R="alsa_input.usb-0d8c_USB_Sound_Device-00.iec958-stereo:capture_FR"
readonly E30_L="alsa_output.usb-Topping_E30-00.pro-output-0:playback_AUX0"
readonly E30_R="alsa_output.usb-Topping_E30-00.pro-output-0:playback_AUX1"

# Check if links exist with more efficient single pattern match
if pw-link -I -l | grep -A1 "$CM106_L" | grep -q "|->.*$E30_L"; then
	# Links exist, disconnect them
	pw-link -d "$CM106_L" "$E30_L"
	pw-link -d "$CM106_R" "$E30_R"
	notify-send "Laptop Audio" "Disconnected from headphones" -t 2000
else
	# Links don't exist, connect them
	pw-link "$CM106_L" "$E30_L"
	pw-link "$CM106_R" "$E30_R"
	notify-send "Laptop Audio" "Connected to headphones" -t 2000
fi