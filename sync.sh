#!/bin/bash

# Omarchy Settings Sync Tool for ykc

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# List of directories to manage
DIRS=("hypr" "waybar" "walker" "mako" "omarchy" "alacritty" "kitty" "ghostty")

function usage() {
    echo "Usage: $0 {save|check|restore}"
    echo "  save    : Copy system configs TO this repository"
    echo "  check   : Show differences between system configs and this repository"
    echo "  restore : Copy repository configs TO system (Overwrites system configs!)"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

COMMAND=$1

case "$COMMAND" in
    save)
        echo "Saving settings from system to repository..."
        for dir in "${DIRS[@]}"; do
            if [ -d "$CONFIG_DIR/$dir" ]; then
                echo "Backing up $dir..."
                rm -rf "$REPO_DIR/configs/$dir"
                cp -r "$CONFIG_DIR/$dir" "$REPO_DIR/configs/"
            else
                echo "Warning: $CONFIG_DIR/$dir does not exist."
            fi
        done
        echo "Done. Don't forget to git commit!"
        ;;
    check)
        echo "Checking for differences..."
        for dir in "${DIRS[@]}"; do
            if [ -d "$CONFIG_DIR/$dir" ] && [ -d "$REPO_DIR/configs/$dir" ]; then
                diff -r --color=auto "$REPO_DIR/configs/$dir" "$CONFIG_DIR/$dir"
            else
                echo "Skipping $dir (missing in one location)"
            fi
        done
        ;;
    restore)
        echo "WARNING: This will overwrite your current system configurations with the ones in this repository."
        read -p "Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for dir in "${DIRS[@]}"; do
                if [ -d "$REPO_DIR/configs/$dir" ]; then
                    echo "Restoring $dir..."
                    # Backup existing just in case
                    if [ -d "$CONFIG_DIR/$dir" ]; then
                         mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/${dir}.bak.$(date +%s)"
                    fi
                    cp -r "$REPO_DIR/configs/$dir" "$CONFIG_DIR/"
                fi
            done
            echo "Restore complete. You may need to reload hyprland or restart apps."
        else
            echo "Cancelled."
        fi
        ;;
    *)
        usage
        ;;
esac
