#!/usr/bin/env bash
set -uo pipefail

json=$("$HOME/.config/omarchy/bar/scripts/orca-items.sh" 2>/dev/null) || exit 0
text=$(jq -r '.text // ""' <<<"$json" 2>/dev/null)
tooltip=$(jq -r '.tooltip // ""' <<<"$json" 2>/dev/null)
printf '%s\n%s\n' "$text" "$tooltip" | wl-copy
notify-send "Orca items" "サマリをコピーしました"
