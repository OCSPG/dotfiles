#!/bin/bash
set -euo pipefail

# VPN script for waybar - Mullvad VPN control and status
# Left click: Connect to random German server
# Right click: Connect to random European server (excluding Germany)

get_status() {
    # Check if mullvad is available
    if ! command -v mullvad >/dev/null 2>&1; then
        echo "ERR"
        return 1
    fi
    
    # Single mullvad call with efficient awk processing
    mullvad status 2>/dev/null | awk '
    BEGIN {
        # Associative array for country code mapping
        codes["Germany"] = "DE"
        codes["Austria"] = "AT"
        codes["Belgium"] = "BE"
        codes["Bulgaria"] = "BG"
        codes["Croatia"] = "HR"
        codes["Cyprus"] = "CY"
        codes["Czech Republic"] = "CZ"
        codes["Denmark"] = "DK"
        codes["Estonia"] = "EE"
        codes["Finland"] = "FI"
        codes["France"] = "FR"
        codes["Greece"] = "GR"
        codes["Hungary"] = "HU"
        codes["Ireland"] = "IE"
        codes["Italy"] = "IT"
        codes["Netherlands"] = "NL"
        codes["Norway"] = "NO"
        codes["Poland"] = "PL"
        codes["Portugal"] = "PT"
        codes["Romania"] = "RO"
        codes["Slovakia"] = "SK"
        codes["Slovenia"] = "SI"
        codes["Spain"] = "ES"
        codes["Sweden"] = "SE"
        codes["Switzerland"] = "CH"
        codes["UK"] = "GB"
    }
    /Connected/ { connected = 1 }
    /Visible location:/ {
        if (connected) {
            # Extract country (everything before first comma)
            gsub(/.*Visible location: */, "")
            gsub(/,.*/, "")
            country = $0
            if (country in codes) {
                print codes[country]
            } else {
                print country
            }
            exit
        }
    }
    END {
        if (!connected) print "OFF"
    }'
}

connect_germany() {
    if ! command -v mullvad >/dev/null 2>&1; then
        notify-send "VPN Error" "Mullvad CLI not found" -t 3000
        return 1
    fi
    
    mullvad relay set location de >/dev/null 2>&1 || return 1
    mullvad connect >/dev/null 2>&1 || return 1
    
    # Show notification with connection details using efficient awk
    sleep 2
    mullvad status 2>/dev/null | awk '
    /Connected/ { connected = 1 }
    /Relay:/ { relay = $2 }
    /Visible location:/ {
        gsub(/.*Visible location: */, "")
        location = $0
    }
    END {
        if (connected && relay && location) {
            system("notify-send \"VPN Connected\" \"Relay: " relay "\\nLocation: " location "\" -t 3000")
        }
    }'
}

connect_europe() {
    if ! command -v mullvad >/dev/null 2>&1; then
        notify-send "VPN Error" "Mullvad CLI not found" -t 3000
        return 1
    fi
    
    # EU + European countries excluding Germany (from available mullvad countries)
    eu_countries=("at" "be" "bg" "hr" "cy" "cz" "dk" "ee" "fi" "fr" "gr" "hu" "ie" "it" "nl" "no" "pl" "pt" "ro" "sk" "si" "es" "se" "ch" "gb")
    random_country=${eu_countries[$RANDOM % ${#eu_countries[@]}]}
    
    mullvad relay set location "$random_country" >/dev/null 2>&1 || return 1
    mullvad connect >/dev/null 2>&1 || return 1
    
    # Show notification with connection details using efficient awk
    sleep 2
    mullvad status 2>/dev/null | awk '
    /Connected/ { connected = 1 }
    /Relay:/ { relay = $2 }
    /Visible location:/ {
        gsub(/.*Visible location: */, "")
        location = $0
    }
    END {
        if (connected && relay && location) {
            system("notify-send \"VPN Connected\" \"Relay: " relay "\\nLocation: " location "\" -t 3000")
        }
    }'
}

disconnect_vpn() {
    mullvad disconnect >/dev/null 2>&1
    notify-send "VPN Disconnected" "Mullvad VPN has been disconnected" -t 3000
}

case "${1:-}" in
    "connect-de")
        connect_germany
        ;;
    "connect-eu")
        connect_europe
        ;;
    "disconnect")
        disconnect_vpn
        ;;
    *)
        get_status
        ;;
esac