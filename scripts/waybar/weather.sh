#!/bin/bash
set -euo pipefail

# Weather script for waybar - uses wttr.in API for weather data
# Optimized for minimal network calls and fast execution

CITY="Stadtroda"  # Change to your city
CACHE_FILE="/tmp/weather_cache"
CACHE_DURATION=600  # 10 minutes
FALLBACK_CACHE_DURATION=3600  # 1 hour for fallback cache

# Weather icon mapping using associative array for efficiency
declare -A weather_icons=(
    ["Clear"]=""
    ["Sunny"]=""
    ["Partly cloudy"]=""
    ["Partly Cloudy"]=""
    ["Cloudy"]=""
    ["Overcast"]=""
    ["Rain"]=""
    ["Drizzle"]=""
    ["Shower"]=""
    ["Snow"]=""
    ["Blizzard"]="🌨️"
    ["Thunder"]=""
    ["Storm"]=""
    ["Fog"]="🌫️"
    ["Mist"]="🌫️"
    ["Wind"]="💨"
)

get_weather_icon() {
    local condition="$1"
    # Check for specific weather patterns
    case "$condition" in
        *"Clear"*|*"Sunny"*) echo "" ;;
        *"Partly cloudy"*|*"Partly Cloudy"*) echo "" ;;
        *"Cloudy"*|*"Overcast"*) echo "" ;;
        *"Rain"*|*"Drizzle"*|*"Shower"*) echo "" ;;
        *"Snow"*|*"Blizzard"*) echo "" ;;
        *"Thunder"*|*"Storm"*) echo "" ;;
        *"Fog"*|*"Mist"*) echo "🌫️" ;;
        *"Wind"*) echo "💨" ;;
        *) echo "🌡️" ;;  # Default icon
    esac
}

# Efficient cache validation using single stat call
cache_valid() {
    [[ -f "$CACHE_FILE" ]] && (( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) < CACHE_DURATION ))
}

# Check if cache is valid and output it
if cache_valid; then
    cat "$CACHE_FILE"
    exit 0
fi

# Enhanced network request with multiple fallback strategies
fetch_weather() {
    local attempts=0
    local max_attempts=3
    local timeout_values=(5 8 10)
    
    while (( attempts < max_attempts )); do
        local timeout_val=${timeout_values[attempts]}
        
        # Try curl with progressively longer timeouts
        if weather_data=$(timeout "$timeout_val" curl -s \
            --max-time "$timeout_val" \
            --connect-timeout 3 \
            --retry 1 \
            --retry-delay 1 \
            --fail \
            --location \
            --user-agent "waybar-weather/1.0" \
            --cacert /etc/ssl/certs/ca-certificates.crt \
            "wttr.in/$CITY?format=%C+%t" 2>/dev/null); then
            
            # Validate response format
            if [[ "$weather_data" =~ [+-]?[0-9]+°C ]]; then
                echo "$weather_data"
                return 0
            fi
        fi
        
        ((attempts++))
        sleep 1
    done
    
    return 1
}

# Try to fetch new weather data
if weather_data=$(fetch_weather); then
    # Parse response efficiently with single pass
    condition=$(echo "$weather_data" | sed 's/[[:space:]]*[+-][0-9]*°C$//')
    temp=$(echo "$weather_data" | grep -o '[+-]\?[0-9]\+°C' | sed 's/^[[:space:]]*//')
    
    if [[ -n "$condition" && -n "$temp" ]]; then
        icon=$(get_weather_icon "$condition")
        output="$icon $temp"
        
        # Atomic cache update
        echo "$output" > "${CACHE_FILE}.tmp" && mv "${CACHE_FILE}.tmp" "$CACHE_FILE"
        echo "$output"
    else
        echo "🌡️ --°C"
    fi
else
    # Try to use stale cache as fallback (up to 1 hour old)
    if [[ -f "$CACHE_FILE" && $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $FALLBACK_CACHE_DURATION ]]; then
        cat "$CACHE_FILE"
    else
        echo " --°C"
    fi
fi
