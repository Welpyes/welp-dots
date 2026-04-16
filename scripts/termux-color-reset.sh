#!/bin/bash

XRES="$HOME/.Xresources"
OUT="$HOME/.termux/colors.properties"

declare -A colors

while IFS= read -r line; do
    # skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*! ]] && continue
    [[ -z "${line// }" ]] && continue

    # match *colorN, *background, *foreground, *cursor
    if [[ "$line" =~ ^\*([a-zA-Z0-9]+):[[:space:]]*(#[0-9a-fA-F]+) ]]; then
        key="${BASH_REMATCH[1]}"
        val="${BASH_REMATCH[2]}"
        colors["$key"]="$val"
    fi
done < "$XRES"

{
    echo "foreground=${colors[foreground]}"
    echo "background=${colors[background]}"
    echo "cursor=${colors[cursorColor]:-${colors[foreground]}}"
    echo ""
    for i in $(seq 0 15); do
        echo "color$i=${colors[color$i]}"
    done
} > "$OUT"

echo "Written to $OUT"
# reload termux colors
termux-reload-settings 2>/dev/null
