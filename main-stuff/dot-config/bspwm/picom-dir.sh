#!/bin/bash

# Function to get the numerical position of the current desktop
get_desktop_index() {
    # 1. Get list of all desktop IDs in order
    # 2. Find the line number of the currently focused desktop ID
    bspc query -D | grep -n "$(bspc query -D -d focused)" | cut -d: -f1
}

# Initial index
prev_idx=$(get_desktop_index)

# Listen for workspace changes
bspc subscribe desktop_focus | while read -r event; do
    curr_idx=$(get_desktop_index)

    # Safety check: make sure we actually got numbers
    if [[ -z "$curr_idx" || -z "$prev_idx" ]]; then
        continue
    fi

    # Determine direction based on index comparison
    if [ "$curr_idx" -gt "$prev_idx" ]; then
        dir="left"
    elif [ "$curr_idx" -lt "$prev_idx" ]; then
        dir="right"
    else
        # If we didn't actually change index (same workspace), do nothing
        continue
    fi

    # Apply the property to all windows so Picom sees it
    # We use -n .window to avoid errors on empty desktops
    for win in $(bspc query -N -n .window); do
        xprop -id "$win" -f _ANIM_DIRECTION 8s -set _ANIM_DIRECTION "$dir" &
    done

    # Update previous index for the next switch
    prev_idx=$curr_idx
done
