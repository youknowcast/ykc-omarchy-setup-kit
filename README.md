# ykc-omarchy-setup-kit

Personal setup toolkit and configuration backup for **Omarchy Linux** (Hyprland environment).
Maintained by **youknowcast (ykc)**.

## Overview

This repository manages custom configurations, scripts, and application fixes essential for my daily workflow, specifically focusing on **Japanese IME support** and **Window Management**.

## Key Features

- **Hyprland Configs**: Custom keybindings, input settings (`kb_layout = jp`), and window rules.
- **Japanese IME Support**:
  - Force X11/XWayland for Electron apps (Slack, Cursor, Antigravity) to enable `fcitx5`.
  - Custom `.desktop` launchers for stability.
  - Emergency text input script using `zenity`.
- **Custom Scripts**:
  - `window-switcher.sh`: `fzf`-based window switcher.
  - `nvim-cheats`: Quick access to Neovim cheat sheets.
- **Key Remapping**: `keyd` configuration mapping `Right Meta` -> `PrintScreen`.

## Documentation

See [memos.md](./memos.md) for detailed setup logs and configuration notes.
