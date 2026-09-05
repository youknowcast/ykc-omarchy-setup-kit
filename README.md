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
- **Omarchy shell**: バー配置 (`shell.json`)、IME 表示用の自作ウィジェット、ワークスペース名表示プラグイン、Ledge (ファイル一時置き場)。
- **Japanese IME Support**:
  - Browsers (Chromium / Vivaldi) と Slack は Wayland ネイティブ。Chromium M135 で
    `WaylandTextInputV3` が既定になり X11 強制が不要になった。
  - Cursor はまだ X11/XWayland を強制して `fcitx5` を通している。
  - Emergency text input script (GTK3 / Ruby).
- **Custom Scripts**:
  - `window-switcher.sh`: `fzf`-based window switcher.
  - `nvim-cheats`: Quick access to Neovim cheat sheets.
  - `close-window-confirm.sh`: `SUPER + W` で Chromium のみ閉じる前に確認 (zenity)。
- **Key Remapping**: `keyd` configuration mapping `Right Meta` -> `PrintScreen`.
- **Keychron Nape Pro workaround**: レイヤー切替時にファームウェアがハングする既知バグへの回避策。
  udev ルールでベンダーインターフェース (`hidraw`) を安定名で公開し、systemd サービスが常時読み取って
  ファームウェアのブロッキングを防ぐ。詳細は [nape-pro/README.md](./configs/nape-pro/README.md)。

## configs/ の配置

| リポジトリ | 実配置先 |
|---|---|
| `configs/hypr/*.lua`, `scripts/`, `window-switcher.sh` | `~/.config/hypr/` |
| `configs/omarchy/shell.json` | `~/.config/omarchy/shell.json` |
| `configs/omarchy/bar/scripts/ime.sh` | `~/.config/omarchy/bar/scripts/ime.sh` |
| `configs/omarchy/plugins/youknow.workspaces/` | `~/.config/omarchy/plugins/youknow.workspaces/` |
| `configs/omarchy/plugins/bylund.ledge/` | `~/.config/omarchy/plugins/bylund.ledge/` (Ledge: `omarchy plugin add https://github.com/andreas-bylund/omarchy-ledge.git`) |
| `configs/omarchy/branding/` | `~/.config/omarchy/branding/` |
| `configs/alacritty/`, `configs/kitty/`, `configs/ghostty/`, `configs/chromium-flags.conf`, `configs/vivaldi-stable.conf` | `~/.config/` 直下の同名パス |
| `configs/Cursor/` | `~/.config/` 直下の同名パス |
| `configs/local/share/applications/*.desktop` | `~/.local/share/applications/` |
| `configs/keyd/default.conf` | `/etc/keyd/default.conf` (要 root) |
| `configs/nape-pro/90-nape-pro.rules` | `/etc/udev/rules.d/90-nape-pro.rules` (要 root) |
| `configs/nape-pro/nape-pro-reader.sh` | `/usr/local/bin/nape-pro-reader.sh` (要 root) |
| `configs/nape-pro/nape-pro-reader.service` | `/etc/systemd/system/nape-pro-reader.service` (要 root) |

## Documentation

- [system-notes.md](./system-notes.md): OS 設定・構築ノート
- [apps.md](./apps.md): 3rd party アプリの導入・運用メモ
