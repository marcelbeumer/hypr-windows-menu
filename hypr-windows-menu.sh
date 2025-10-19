#!/usr/bin/env bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ${0##*/} [-a]"
    echo "  -a    Show all windows (default: current workspace only)"
    exit 0
fi

if [[ "$1" == "-a" ]]; then
    lines=$(hyprctl clients -j | jq -r '.[] | .address + "\t" + .initialTitle + " - " + .title')
else
    current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
    lines=$(hyprctl clients -j | jq -r --arg ws "$current_ws" '.[] | select(.workspace.id == ($ws | tonumber)) | .address + "\t" + .initialTitle + " - " + .title')
fi

selected_index=$(echo "$lines" | walker -p "Window:" --dmenu -i)

if [ -n "$selected_index" ]; then
    selected_line=$(echo "$lines" | sed -n "$((selected_index + 1))p")
    address=$(echo "$selected_line" | awk '{print $1}')
    hyprctl dispatch focuswindow "address:$address"
fi
