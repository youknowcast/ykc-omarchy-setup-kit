# Omarchy セットアップログ

Youknowcast (ykc) 用の Omarchy 設定・構築ログです。
初期セットアップ以降に行われた重要な変更点や、システム復旧時に特に注意すべき点を記録しています。

## 1. 重要な設定変更 (Config Changes)

### Chromium / Electron 系アプリ設定
- **日本語入力対応 (Chromium)**:
    - 設定ファイル: `~/.config/chromium-flags.conf`
    - 変更点: Waylandネイティブではなく **X11 (XWayland)** で動作するように強制。
    - 理由: Waylandネイティブ動作時の日本語入力(IME)不具合を回避するため。
    - 設定値: `--ozone-platform=x11`, `--ozone-platform-hint=x11`

### Hyprland 設定
- **キーボードレイアウト**: `input.conf` にて `kb_layout = jp` に変更済み。
- **ウィンドウ切り替え (Window Switcher)**:
    - バインディング: `SUPER + CTRL + RETURN`
    - 動作: 現在開いているウィンドウを `fzf` で一覧表示し、選択してフォーカスするスクリプトを実行。
    - 関連ファイル: `~/.config/hypr/window-switcher.sh`
- **緊急用日本語入力**:
    - バインディング: 未設定（必要に応じて実行）
    - 動作: IMEが効かない環境用に `zenity` を使ったテキスト入力・コピー機能。
    - 関連ファイル: `~/.config/hypr/omarchy-emergency-jp-input/launch.sh`

### キーバインディング (`bindings.conf`)
主要なカスタムショートカット:
- `SUPER + SHIFT + F`: ファイルマネージャー (Nautilus)
- `SUPER + SHIFT + N`: エディタ
- `SUPER + SHIFT + O`: Obsidian (IME有効化オプション付き)
- `SUPER + SHIFT + W`: Typora (IME有効化オプション付き)
- `SUPER + SHIFT + /`: 1Password
- `SUPER + SHIFT + A`: ChatGPT
- `SUPER + SHIFT + ALT + A`: Grok

### キーリマッピング (Key Remapping)
`keyd` を使用してキーの物理的な割り当てを変更しています。
- **設定ファイル**: `/etc/keyd/default.conf` (root権限が必要)
- **変更内容**: `rightmeta` (Right Command/Win) → `print` (PrintScreen)
- **関連ファイル**: `configs/keyd/default.conf` にバックアップあり。

## 2. 日本語入力対応 (Japanese IME Support)

Wayland環境下のElectronアプリで日本語入力を可能にするため、アプリごとに異なる対策を行っています。

- **Obsidian / Typora**: `--enable-wayland-ime` オプションを付与して起動。
- **Chromium / Chrome**: `chromium-flags.conf` にて X11 バックエンドを強制使用。
- **Cursor (Editor)**:
    - **設定ファイル**: `~/.local/share/applications/cursor.desktop` (起動ショートカット)
    - **変更点**: X11強制、IMEモジュール指定、スケーリング調整。
    - **起動コマンド**: `env OZONE_PLATFORM=x11 ELECTRON_OZONE_PLATFORM_HINT=x11 SDL_IM_MODULE=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx ELECTRON_FORCE_DEVICE_SCALE_FACTOR=0.7 /usr/share/cursor/cursor %F`
    - **ユーザー設定**: `~/.config/Cursor/User/settings.json` (ズームレベル等)
    - **バックアップ**: `configs/local/share/applications/cursor.desktop`, `configs/Cursor/User/settings.json`
- **Slack / Antigravity**:
    - **設定ファイル**: `~/.local/share/applications/{slack,antigravity}.desktop`
    - **変更点**: X11強制、IMEモジュール指定 (Cursorと同様の環境変数を使用)。
    - **バックアップ**: `configs/local/share/applications/{slack,antigravity}.desktop`

## 3. 追加スクリプト (Custom Scripts)

### `window-switcher.sh`
- **依存**: `hyprctl`, `jq`, `fzf`
- **内容**: 全ワークスペースのウィンドウ情報を取得し、インクリメンタルサーチで選択可能にする。

### `omarchy-emergency-jp-input/launch.sh`
- **ソース**: [omarchy-emergency-jp-input](https://github.com/youknowcast/omarchy-emergency-jp-input)
- **依存**: `zenity`, `wl-clipboard`
- **内容**: 簡易的なテキスト入力ダイアログを表示し、入力内容をクリップボードにコピーする。

### `scripts/nvim-cheats.sh`
- **ソース**: [nvim-cheats](https://github.com/youknowcast/nvim-cheats)
- **依存**: `fzf`
- **内容**: Neovimのチートシートを表示・検索するスクリプト。
- **データ**: `scripts/data/` 以下にチートシートデータを配置。

## 4. インストール済みアプリケーション・依存ツール
セットアップ時に追加インストールが必要なもの：

- **必須ツール**: `fzf`, `jq`, `zenity`, `wl-clipboard`
- **アプリケーション**:
    - Ghostty (Terminal)
    - Obsidian
    - Typora
    - 1Password
    - Google Chrome / Chromium (Web Apps用)
