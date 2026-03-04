#!/bin/bash

# Get active windows
active_windows=$(eww active-windows)

# Check if simple-calendar is in the list
if echo "$active_windows" | grep -q "simple-calendar"; then
    eww close simple-calendar
else
    eww open simple-calendar
fi
