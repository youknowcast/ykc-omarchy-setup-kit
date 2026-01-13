#!/bin/bash

selected=$(hyprctl clients -j | jq -r '.[] | select(.title != "Ghostty") | "\(.address)|\(.class)|\(.title)"' | fzf --prompt="Window: ")
[ -n "$selected" ] && hyprctl dispatch focuswindow "address:$(echo "$selected" | cut -d'|' -f1)"
