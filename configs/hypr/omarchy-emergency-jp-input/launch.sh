#!/bin/bash

# Configuration
APP_TITLE="Emergency JP Input"
WIDTH=600
HEIGHT=400

# Check dependencies
if ! command -v zenity &> /dev/null; then
    notify-send -u critical "Error" "zenity is missing. Please install it."
    exit 1
fi

if ! command -v wl-copy &> /dev/null; then
    notify-send -u critical "Error" "wl-copy is missing. Please install wl-clipboard."
    exit 1
fi

# Launch Zenity in Text Info mode (Multi-line)
# --text-info: Text box mode
# --editable: Allow editing
# --font: Larger font for visibility
# --ok-label: Hint that Ctrl+Enter works (standard GTK behavior for textviews) or they can click it.
TEXT=$(zenity --text-info \
    --editable \
    --title="$APP_TITLE" \
    --width=$WIDTH \
    --height=$HEIGHT \
    --ok-label="Copy (Ctrl+Enter)" \
    --cancel-label="Cancel" \
    --font="Sans 14")

# Check exit status of Zenity (0 = OK)
if [ $? -eq 0 ] && [ -n "$TEXT" ]; then
    # Copy to clipboard
    # -n removes the trailing newline if you want exact text, 
    # but for Japanese paragraphs, usually we just pipe it.
    echo -n "$TEXT" | wl-copy
    
    # Notify user
    notify-send "Copied!" "Text has been copied to clipboard."
fi
