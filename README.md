# ykc-omarchy-setup-kit

Personal setup toolkit and configuration backup for **Omarchy Linux** (Hyprland environment).
Maintained by **youknowcast (ykc)**.

対象バージョン: **Omarchy 4.x (Quattro)**

## Overview

This repository manages custom configurations, scripts, and application fixes essential for my daily workflow, specifically focusing on **Japanese IME support** and **Window Management**.

Quattro でユーザ設定は Lua ベース (`~/.config/hypr/*.lua`) に、ステータスバー/通知/ロックは
Quickshell 製の **Omarchy shell** (`~/.config/omarchy/shell.json`) に置き換わりました。
このリポジトリには **既定値から変更した設定だけ** を置いています。

## Key Features

- **Hyprland Configs (Lua)**: キーバインド上書き、ウィンドウルール、fcitx5/GPU 向け環境変数。
- **Omarchy shell**: バー配置 (`shell.json`)、IME 表示用の自作ウィジェット、ワークスペース名表示プラグイン。
- **Japanese IME Support**:
  - Browsers (Chromium / Vivaldi) と Slack は Wayland ネイティブ。Chromium M135 で
    `WaylandTextInputV3` が既定になり X11 強制が不要になった。
  - Cursor はまだ X11/XWayland を強制して `fcitx5` を通している。
  - Emergency text input script (GTK3 / Ruby).
- **Custom Scripts**:
  - `window-switcher.sh`: `fzf`-based window switcher.
  - `nvim-cheats`: Quick access to Neovim cheat sheets.
- **Key Remapping**: `keyd` configuration mapping `Right Meta` -> `PrintScreen`.

## configs/ の配置

| リポジトリ | 実配置先 |
|---|---|
| `configs/hypr/*.lua`, `scripts/`, `window-switcher.sh` | `~/.config/hypr/` |
| `configs/omarchy/shell.json` | `~/.config/omarchy/shell.json` |
| `configs/omarchy/bar/scripts/ime.sh` | `~/.config/omarchy/bar/scripts/ime.sh` |
| `configs/omarchy/plugins/youknow.workspaces/` | `~/.config/omarchy/plugins/youknow.workspaces/` |
| `configs/omarchy/branding/` | `~/.config/omarchy/branding/` |
| `configs/alacritty/`, `configs/kitty/`, `configs/ghostty/`, `configs/chromium-flags.conf`, `configs/vivaldi-stable.conf` | `~/.config/` 直下の同名パス |
| `configs/Cursor/` | `~/.config/` 直下の同名パス |
| `configs/local/share/applications/*.desktop` | `~/.local/share/applications/` |
| `configs/keyd/default.conf` | `/etc/keyd/default.conf` (要 root) |

## Documentation

- [system-notes.md](./system-notes.md): OS 設定・構築ノート
- [apps.md](./apps.md): 3rd party アプリの導入・運用メモ
