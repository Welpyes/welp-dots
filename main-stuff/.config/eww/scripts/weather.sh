#!/bin/bash

LAT="9.3068
LON="123.3080"
CACHE_DIR="$HOME/.cache/eww"
CACHE_FILE="$CACHE_DIR/weather.json"
CACHE_TTL=900

update_cache() {
    mkdir -p "$CACHE_DIR"
    if [[ ! -f "$CACHE_FILE" ]] || [[ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -gt $CACHE_TTL ]]; then
        curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m&timezone=auto" > "$CACHE_FILE"
    fi
}

get_icon() {
    local code=$1
    local is_day=$2
    case $code in
        0) [[ $is_day -eq 1 ]] && echo "󰖙" || echo "󰖔" ;; # Clear
        1|2|3) [[ $is_day -eq 1 ]] && echo "󰖕" || echo "󰼱" ;; # Partly Cloudy
        45|48) echo "󰖑" ;; # Fog
        51|53|55|61|63|65|80|81|82) echo "󰖗" ;; # Rain
        71|73|75|77|85|86) echo "󰖘" ;; # Snow
        95|96|99) echo "󰙒" ;; # Thunderstorm
        *) echo "󰖐" ;;
    esac
}

# Map WMO weather codes to descriptions
get_desc() {
    case $1 in
        0) echo "Clear" ;;
        1|2|3) echo "Cloudy" ;;
        45|48) echo "Foggy" ;;
        51|53|55) echo "Drizzle" ;;
        61|63|65) echo "Rainy" ;;
        80|81|82) echo "Showers" ;;
        95|96|99) echo "Thunder" ;;
        *) echo "Unknown" ;;
    esac
}

# Main execution
update_cache

case $1 in
    icon)
        get_icon "$(jq -r '.current.weather_code' "$CACHE_FILE")" "$(jq -r '.current.is_day' "$CACHE_FILE")"
        ;;
    temp)
        jq -r '.current.temperature_2m | round | tostring + "°C"' "$CACHE_FILE"
        ;;
    heat-index)
        jq -r '.current.apparent_temperature | round | tostring + "°C"' "$CACHE_FILE"
        ;;
    humidity)
        jq -r '.current.relative_humidity_2m | tostring + "%"' "$CACHE_FILE"
        ;;
    wind)
        jq -r '.current.wind_speed_10m | tostring + " km/h"' "$CACHE_FILE"
        ;;
    desc)
        get_desc "$(jq -r '.current.weather_code' "$CACHE_FILE")"
        ;;
    all)
        # Output everything as JSON for efficient eww polling
        icon=$(get_icon "$(jq -r '.current.weather_code' "$CACHE_FILE")" "$(jq -r '.current.is_day' "$CACHE_FILE")")
        desc=$(get_desc "$(jq -r '.current.weather_code' "$CACHE_FILE")")
        temp=$(jq -r '.current.temperature_2m | round' "$CACHE_FILE")
        heat=$(jq -r '.current.apparent_temperature | round' "$CACHE_FILE")
        hum=$(jq -r '.current.relative_humidity_2m' "$CACHE_FILE")
        wind=$(jq -r '.current.wind_speed_10m' "$CACHE_FILE")
        
        printf '{"icon":"%s","desc":"%s","temp":"%s°C","heat":"%s°C","hum":"%s%%","wind":"%s km/h"}\n' \
            "$icon" "$desc" "$temp" "$heat" "$hum" "$wind"
        ;;
    *)
        echo "Usage: $0 {icon|temp|heat-index|humidity|wind|desc|all}"
        exit 1
        ;;
esac
