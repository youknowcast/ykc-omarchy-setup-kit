#!/bin/bash

# Define colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
GRAY="\033[90m"

# Resolve script directory to find data files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

# Select data source based on locale
if [[ "$LANG" == *"ja"* ]]; then
    DATA_FILE="$DATA_DIR/ja"
    PROMPT="nvim(ja)> "
else
    DATA_FILE="$DATA_DIR/en"
    PROMPT="nvim(en)> "
fi

# Fallback if data file missing
if [ ! -f "$DATA_FILE" ]; then
    # Try English as fallback
    DATA_FILE="$DATA_DIR/en"
    PROMPT="nvim(fallback)> "
    if [ ! -f "$DATA_FILE" ]; then
        echo "Error: Data file not found in $DATA_DIR"
        exit 1
    fi
fi

# Use awk to format data
# Output format: Command Description [Tags]
cat "$DATA_FILE" | awk -v blue="$BLUE" -v green="$GREEN" -v reset="$RESET" -v bold="$BOLD" -v gray="$GRAY" '
    /^#/ { 
        print blue bold $0 reset
        next 
    }
    /^[[:space:]]*$/ { next }
    { 
        # Split line into parts
        match($0, /^[[:graph:]]+/)
        cmd = substr($0, RSTART, RLENGTH)
        remain = substr($0, RSTART + RLENGTH)
        
        # Extract Tags
        desc = remain
        extracted_tags = ""
        while (match(desc, /\[[^]]+\]/)) {
            t = substr(desc, RSTART, RLENGTH)
            extracted_tags = extracted_tags t
            sub(/\[[^]]+\]/, "", desc)
        }
        
        # Clean up description
        gsub(/^[[:space:]]+/, "", desc)
        gsub(/[[:space:]]+$/, "", desc)
        
        # Output: Command (Green) Description [Tags] (Gray)
        # Using minimal spacing (1 space) between description and tags
        printf "%s%-12s%s %s %s%s%s\n", green, cmd, reset, desc, gray, extracted_tags, reset
    }
' | fzf \
    --ansi \
    --header="Type to filter..." \
    --layout=reverse \
    --border \
    --margin=1 \
    --padding=1 \
    --prompt="$PROMPT" \
    --pointer="▶" \
    --marker="✓" \
    --no-info \
    --cycle

# Exit logic is handled by terminal window closing or ESC in fzf
