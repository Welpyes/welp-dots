#!/bin/bash

# Get active windows
active_windows=$(eww active-windows)

# Check if simple-calendar is in the list
if echo "$active_windows" | grep -q "pallete"; then
    eww close pallete
else
    eww open pallete
fi
