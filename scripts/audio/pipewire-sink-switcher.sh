#!/bin/bash

# PipeWire Audio Sink Switcher
# Switches between two specific audio sinks and shows notification

set -euo pipefail

# Define sink names
readonly SINK1="alsa_output.pci-0000_18_00.6.analog-stereo"
readonly SINK1_NAME="HD Audio Controller"
readonly SINK2="alsa_output.usb-Topping_E30-00.pro-output-0"
readonly SINK2_NAME="E30 Pro"

# Cache sink list for multiple operations
SINK_LIST=""

# Function to get current default sink
get_current_sink() {
	pactl get-default-sink
}

# Function to get sink list (cached)
get_sink_list() {
	if [[ -z "$SINK_LIST" ]]; then
		SINK_LIST=$(pactl list short sinks)
	fi
	echo "$SINK_LIST"
}

# Function to check if a sink exists (optimized)
sink_exists() {
	local sink="$1"
	grep -q "^[0-9]*[[:space:]]*${sink}[[:space:]]" <<< "$(get_sink_list)"
}

# Function to set default sink
set_default_sink() {
	local sink="$1"
	pactl set-default-sink "$sink"
}

# Function to move all streams to new sink (optimized)
move_all_streams() {
	local new_sink="$1"
	
	# Get all sink inputs and move them in one efficient operation
	local inputs
	inputs=$(pactl list short sink-inputs 2>/dev/null | cut -f1) || return 0
	
	[[ -n "$inputs" ]] || return 0
	
	# Move each stream to the new sink
	while IFS= read -r input; do
		[[ -n "$input" ]] && pactl move-sink-input "$input" "$new_sink" 2>/dev/null || true
	done <<< "$inputs"
}

# Function to get sink status (optimized with awk)
get_sink_status() {
	local sink="$1"
	pactl list sinks 2>/dev/null | awk -v sink="$sink" '
		/^Sink #/ { current_sink = "" }
		$1 == "Name:" && $2 == sink { current_sink = sink }
		current_sink == sink && /^\s*State:/ { print $2; exit }
	'
}

# Function to send notification
send_notification() {
    local sink_name=$1
    local status=$2
    
    # Create notification with icon
    notify-send -a "Audio Switcher" \
                -i audio-volume-high \
                -t 2000 \
                -u normal \
                "Audio Output Switched" \
                "Now using: $sink_name"
}

# Main logic
main() {
	# Check if both sinks exist (using cached list)
	if ! sink_exists "$SINK1"; then
		notify-send -a "Audio Switcher" \
		            -i dialog-error \
		            -t 3000 \
		            -u critical \
		            "Audio Switch Failed" \
		            "$SINK1_NAME not found"
		exit 1
	fi
	
	if ! sink_exists "$SINK2"; then
		notify-send -a "Audio Switcher" \
		            -i dialog-error \
		            -t 3000 \
		            -u critical \
		            "Audio Switch Failed" \
		            "$SINK2_NAME not found"
		exit 1
	fi
	
	# Get current sink
	local current_sink
	current_sink=$(get_current_sink)
	
	# Determine which sink to switch to
	local new_sink new_sink_name
	if [[ "$current_sink" == "$SINK1" ]]; then
		new_sink="$SINK2"
		new_sink_name="$SINK2_NAME"
	else
		new_sink="$SINK1"
		new_sink_name="$SINK1_NAME"
	fi
	
	# Check if the target sink is suspended and try to resume it
	local sink_status
	sink_status=$(get_sink_status "$new_sink")
	if [[ "$sink_status" == "SUSPENDED" ]]; then
		# Try to wake up the sink by setting it as default first
		set_default_sink "$new_sink"
		sleep 0.1  # Give it a moment to wake up
	fi
	
	# Set the new default sink
	if set_default_sink "$new_sink"; then
		# Move all active streams to the new sink
		move_all_streams "$new_sink"
		
		# Send success notification
		send_notification "$new_sink_name" "$sink_status"
		
		# Exit successfully
		exit 0
	else
		# Send error notification
		notify-send -a "Audio Switcher" \
		            -i dialog-error \
		            -t 3000 \
		            -u critical \
		            "Audio Switch Failed" \
		            "Could not switch to $new_sink_name"
		exit 1
	fi
}

# Run main function
main