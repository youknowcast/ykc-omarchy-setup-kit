#!/bin/bash

target_class="chromium"

class=$(hyprctl activewindow -j | jq -r '.class')

close_active() {
    hyprctl dispatch "hl.dsp.window.close()" >/dev/null
}

if [[ "$class" == "$target_class" ]]; then
    if zenity --question --title="Close window?" --text="Close this Chromium window?"; then
        close_active
    fi
else
    close_active
fi