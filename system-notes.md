# Omarchy システムノート

Youknowcast (ykc) 用の Omarchy 設定・構築ノートです。
初期セットアップ以降に行われた重要な変更点や、システム復旧時に特に注意すべき点を記録しています。

対象: **Omarchy 4.x (Quattro)**

## 0. Quattro での構成変更 (v3 からの移行メモ)

- Hyprland のユーザ設定は `.conf` から **Lua** へ移行 (`~/.config/hypr/*.lua`)。
  `hyprland.lua` が `require("default.hypr.omarchy")` で既定値を読み込み、
  `monitors / input / bindings / looknfeel / autostart` の各 Lua で上書きする。
  設定 API は `hl.*` (Hyprland 生設定) と `o.*` (Omarchy ヘルパー)。
- **waybar / walker / mako / swayosd / hyprlock / hypridle は廃止**。
  バー・ランチャー・通知・OSD・ロック・アイドルは Quickshell 製の
  **Omarchy shell** (`quickshell -p /usr/share/omarchy/shell`) に統合された。
  設定は `~/.config/omarchy/shell.json` の一箇所。
- テーマの実体は `~/.config/omarchy/current/` から
  **`~/.local/state/omarchy/current/`** へ移動 (生成物なのでリポジトリでは管理しない)。
  端末設定の `include` / `config-file` パスもこれに合わせて変更済み。
- Omarchy 本体は `~/.local/share/omarchy/` から **`/usr/share/omarchy/`** (パッケージ管理) へ移動。
- フック は `~/.config/omarchy/hooks/<event>.sample` から
  **`~/.config/omarchy/hooks/<event>.d/`** ディレクトリ方式へ。
- コマンド体系が `omarchy <group> <action>` に統一 (`omarchy commands` で一覧)。

### 移行で既定値に戻った設定 (意図的に追従しているもの)

- `input`: `kb_layout` は Quattro が `/etc/vconsole.conf` の `XKBLAYOUT` から自動導出する
  (このマシンは `XKBLAYOUT=jp` なので **jp のまま**)。`repeat_rate` / `numlock_by_default` /
  タッチパッドの `scroll_factor` / 端末の `scroll_touchpad` はすべて Quattro の既定値に含まれた。
  よって `input.lua` に残す独自設定は `kb_options` のみ。
- `looknfeel`: 旧 `rounding = 8` は引き継がず、Quattro 既定の `rounding = 0` を使用中。
  角丸に戻したくなったら `~/.config/hypr/looknfeel.lua` で `hl.config({ decoration = { rounding = 8 } })`。
- `monitors`: 旧 `monitors.conf` の内容 (`GDK_SCALE=2` + `preferred,auto,auto`) は
  Quattro 既定の `monitors.lua` と同一なので上書き不要。

## 1. 重要な設定変更 (Config Changes)

### Chromium / Electron 系アプリ設定
- **日本語入力対応 (Chromium)**:
    - 設定ファイル: `~/.config/chromium-flags.conf`
    - 現在: **Wayland ネイティブ**。`--ozone-platform=wayland`, `--ozone-platform-hint=wayland`
    - 経緯: 以前は Wayland ネイティブ時の IME 不具合 (切り替えが効いたり永続的に無効になったり
      する非決定的な挙動) を避けるため X11 を強制していた。Chromium **M135 (2025-04)** で
      `WaylandTextInputV3` が default enabled になり、既定で GTK IME 経路が拾われる問題が
      解消されたため、2026-08-19 に Wayland へ戻した (chromium 151 / Hyprland 0.56.2 で検証)。
    - 削除した設定: `--disable-features=WaylandIME`。この feature 名は Chromium に存在せず
      (実在するのは `WaylandTextInputV3`)、未知の feature 名は黙って無視されるため no-op だった。
    - `omarchy-launch-webapp` は既定ブラウザの `--app=` を呼ぶだけなので、webapp 群もこの設定に追随する。
      ただし `ChatGPT.desktop` だけは `vivaldi-stable` を直接指定しているため対象外。
- **日本語入力対応 (Vivaldi)**:
    - 設定ファイル: `~/.config/vivaldi-stable.conf` (ラッパー `/opt/vivaldi/vivaldi` が
      `$XDG_CONFIG_HOME/vivaldi-$CHROME_VERSION_EXTRA.conf` を読む。stable 版なので `vivaldi-stable.conf`)
    - 現在: **Wayland ネイティブ**。`--ozone-platform=wayland`, `--ozone-platform-hint=wayland`
    - 経緯: 本来 Vivaldi を常用したいが、Chromium と同じ Wayland IME 問題のため
      やむなく chromium を使っていた。Vivaldi 8.1 は **Chromium 150 ベース**で M135 より先のため
      同じ理屈で解消済み。2026-08-19 に検証して Wayland へ移行。
    - `~/.local/share/applications/vivaldi-stable.desktop` から `env OZONE_PLATFORM=x11` を除去。
      このファイルはパッケージ版との差分が上記と MimeType への `x-scheme-handler/ftp` /
      `mailto` 追加だけなので、後者のためにユーザー側ファイルを残している。
    - **chromium からあえてコピーしていないフラグ**:
        - `--password-store=gnome-libsecret`: 既存プロファイルのパスワードストアを変更すると
          保存済みパスワードが読めなくなる恐れがあるため。
        - `--force-device-scale-factor=1.2`: Vivaldi 側は UI ズーム未設定 (等倍) で使ってきたため。
        - `--enable-features=TouchpadOverscrollHistoryNavigation`: Vivaldi は独自のジェスチャ設定を持つため。
    - **未実施**: デフォルトブラウザの切り替え (`xdg-settings set default-web-browser vivaldi-stable.desktop`)。
      実行すると `omarchy-launch-webapp` 経由の webapp 群が一斉に Vivaldi 起動へ変わるため、
      使用感を見てから判断する。

### Hyprland 設定 (`~/.config/hypr/*.lua`)

- **`input.lua`**: `kb_options = "compose:caps"`。
  Omarchy 既定の `shift:both_capslock_cancel` を外している。理由は
  JetBrains IDE (2026.1+ / ネイティブ Wayland) で Shift 2度押しの Search Everywhere が
  発火しなくなるため (Shift リリース時の keysym が Caps_Lock になり、修飾キー2連打判定が成立しない)。
  代償として「両 Shift 同時押しで Caps Lock トグル」は無効。
- **`hyprland.lua`**: ウィンドウルールと環境変数。
    - `cursor` → workspace 2 / `antigravity` → workspace 3 に自動配置。
    - 全ウィンドウ `opacity 0.80`、`special:scratchpad` は `0.40`。
    - window-switcher / Emergency JP Input / nvim-cheats をフロート中央表示。
    - `dev.youknow.miryam` の会話・ニュース窓をフロート中央表示。
    - `GTK_IM_MODULE=fcitx` (後述)。
    - `__EGL_VENDOR_LIBRARY_FILENAMES` / `__GLX_VENDOR_LIBRARY_NAME` を mesa 固定 (後述)。
- **`bindings.lua`**: 既定バインドを `hl.unbind()` してから `o.bind()` で上書きする方式。
    - `SUPER + CTRL + RETURN`: window-switcher (既定は Herdr)
    - `SUPER + SHIFT + G`: GitHub (既定は Signal)
    - `SUPER + SHIFT + W`: Typora (既定は Omawrite)
    - `SUPER + SHIFT + C`: Google Calendar (既定は hey.com)
    - `SUPER + SHIFT + E`: Gmail (既定は hey.com)
    - `SUPER + SHIFT + T`: btop
    - `SUPER + U`: 緊急日本語入力
    - `SUPER + I`: nvim-cheats
    - 現在の全バインド確認: `omarchy menu keybindings --print`
- **`autostart.lua`**: 起動時に vivaldi / ghostty を起動 (未起動時のみ)。
  Vivaldi の起動判定は `pgrep -x vivaldi-bin` (実行バイナリは `/opt/vivaldi/vivaldi-bin`。
  `vivaldi-stable` は `/opt/vivaldi/vivaldi` ラッパーへの symlink なので `-x` では引っかからない)。

### GPU (EGL/GLX ベンダ固定)
- **設定ファイル**: `~/.config/hypr/hyprland.lua`
- **内容**: `__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json`,
  `__GLX_VENDOR_LIBRARY_NAME=mesa`
- **理由**: このマシンは AMD 780M のみ (NVIDIA GPU 無し) だが `nvidia-utils` が
  `10_nvidia.json` を置くため libglvnd が NVIDIA EGL を読み込み、chromium の GPU プロセスが
  SEGV → GPU 無効化にフォールバックして WebGL が全滅する (Figma が "WebGL isn't supported")。
- **2026-08-19 に `nvidia-utils` 本体を削除して根本解決**:
  `pacman -Rs nvidia-utils` で `egl-x11` / `egl-wayland` / `egl-wayland2` / `egl-gbm` /
  `eglexternalplatform` も同時に削除。`opengl-driver` は mesa、`vulkan-driver` は
  vulkan-radeon が提供するため連鎖削除は発生しない。`egl_vendor.d` は `50_mesa.json` のみになった。
- **上記 2 行は冗長になったが保険として残置**。`nvidia-utils` は明示インストールではなく
  依存として入っていたため、再び引き込まれる可能性がある。
- **注意**: Hyprland の `env =` は**設定読み込み時にしか適用されない**。この 2 行を追加しても
  Hyprland を再起動するまで既存セッションには一切効かない (2026-08-18 に追加したが未適用のまま
  8/19 に同じクラッシュを2回踏んだ)。
- **注意**: NVIDIA GPU を積む構成に変えたらこの 2 行を削除すること。

### Omarchy shell (バー / 通知 / ロック)
- **設定ファイル**: `~/.config/omarchy/shell.json`
- 独自ウィジェット:
    - `ime` (command 型): `~/.config/omarchy/bar/scripts/ime.sh` を 3 秒間隔で実行し `あ` / `EN` を表示。
      旧 waybar の `ime.sh` を置き換えたもの (`fcitx5-remote --check` で存在確認するよう改善)。
    - `cpu` (command 型): クリックで btop を起動するだけのアイコン。
    - `youknow.workspaces`: 既定の `omarchy.workspaces` を `omarchy plugin clone` した派生。
      ワークスペース番号の代わりに日本語ラベル (`[1]汎用` `[2]仕事用1` ...) を表示し、
      幅を固定せずラベル長に追従させている。実体は
      `~/.config/omarchy/plugins/youknow.workspaces/`。
- 時計フォーマットは `yyyy/MM/dd (ddd) HH:mm`。
- アイドル: スクリーンセーバー 150 秒 / ロック 300 秒 (旧 `hypridle.conf` 相当)。
- 変更は保存で hot-reload。壊したら `omarchy refresh shell` (バックアップが作られる)。

### キーリマッピング (Key Remapping)
`keyd` を使用してキーの物理的な割り当てを変更しています。
- **設定ファイル**: `/etc/keyd/default.conf` (root権限が必要)
- **変更内容**: `rightmeta` (Right Command/Win) → `print` (PrintScreen)
- **関連ファイル**: `configs/keyd/default.conf` にバックアップあり。

## 2. 日本語入力対応 (Japanese IME Support)

Quattro は fcitx5 を標準サポートしており、`INPUT_METHOD` / `QT_IM_MODULE` /
`XMODIFIERS` / `SDL_IM_MODULE` は `/usr/share/omarchy/default/environment.d/10-omarchy-fcitx.conf`
が設定し、fcitx5 自体は `omarchy-fcitx5.service` (systemd user unit) が起動する。
**`GTK_IM_MODULE` だけは Omarchy が設定しない** ので `hyprland.lua` で自前で入れている。

アプリ個別の対策:

- **Obsidian / Typora**: `--enable-wayland-ime` オプションを付与して起動。
- **Chromium**: Wayland ネイティブ。M135 以降は `--enable-wayland-ime` も不要 (1章参照)。
- **Vivaldi**: Wayland ネイティブ。常用ブラウザ。Chromium 150 ベース (1章参照)。
- **Cursor (Editor)**:
    - **設定ファイル**: `~/.local/share/applications/cursor.desktop` (起動ショートカット)
    - **変更点**: X11強制、IMEモジュール指定、スケーリング調整。
    - **起動コマンド**: `env OZONE_PLATFORM=x11 ELECTRON_OZONE_PLATFORM_HINT=x11 SDL_IM_MODULE=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx ELECTRON_FORCE_DEVICE_SCALE_FACTOR=0.7 /usr/share/cursor/cursor %F`
    - **ユーザー設定**: `~/.config/Cursor/User/settings.json` (ズームレベル等)
    - **バックアップ**: `configs/local/share/applications/cursor.desktop`, `configs/Cursor/User/settings.json`
- **Slack**:
    - **設定ファイル**: `~/.local/share/applications/slack.desktop`
    - **現在**: native アプリ版を Wayland ネイティブで起動 (slack-desktop 4.47.69 / Electron 39.2.4 /
      Chrome 142。M135 以降なので IME 問題は解消済み。2026-08-19 に検証)。
    - **起動コマンド**: `/usr/bin/slack --gtk-version=3 --ozone-platform=wayland --ozone-platform-hint=wayland -s %U`
    - **経緯**: 以前は Wayland の IME 不具合を避けるため web 版を Chromium のアプリモード
      (`chromium --app=https://app.slack.com/client`) で起動していた。2026-08-19 に native へ復帰。
    - **注意**: ユーザー側の `slack.desktop` はパッケージ版 `/usr/share/applications/slack.desktop` を
      **shadow する**。`MimeType=x-scheme-handler/slack;` を書き忘れると `slack://` の deep link が
      効かなくなり、ブラウザからのログインが完了できない (web 版時代はこれで詰まった)。
    - **バックアップ**: `configs/local/share/applications/slack.desktop`
- **Antigravity**:
    - **設定ファイル**: `~/.local/share/applications/antigravity.desktop`
    - **ユーザー設定**: `~/.config/Antigravity/User/settings.json` (ズームレベル等)
    - **変更点**: X11強制、IMEモジュール指定 (Cursorと同様の環境変数を使用)。
    - **バックアップ**: `configs/local/share/applications/antigravity.desktop`, `configs/Antigravity/User/settings.json`

## 3. 追加スクリプト (Custom Scripts)

### `window-switcher.sh`
- **依存**: `hyprctl`, `jq`, `fzf`
- **内容**: 全ワークスペースのウィンドウ情報を取得し、インクリメンタルサーチで選択可能にする。
- **バインド**: `SUPER + CTRL + RETURN`

### `scripts/omarchy-emergency-input.sh`
- **ソース**: [omarchy-emergency-jp-input](https://github.com/youknowcast/omarchy-emergency-jp-input)
- **依存**: Ruby + `gtk3` gem, `wl-clipboard`
- **内容**: IMEが効かない環境向けに、GTK3 のテキスト入力ウィンドウを出して
  Ctrl+Enter でクリップボードへコピーする。
- **バインド**: `SUPER + U`
- **備考**: 旧 zenity 版 (`omarchy-emergency-jp-input/launch.sh`) はこの GTK3 版に置き換えたため削除済み。

### `scripts/nvim-cheats.sh`
- **ソース**: [nvim-cheats](https://github.com/youknowcast/nvim-cheats)
- **依存**: `fzf`
- **内容**: Neovimのチートシートを表示・検索するスクリプト。
- **データ**: `scripts/data/` 以下にチートシートデータを配置。
- **バインド**: `SUPER + I`

## 4. 端末設定の共通変更

`alacritty` / `kitty` / `ghostty` に Quattro 既定として入った変更 (追従済み):

- テーマ参照先を `~/.local/state/omarchy/current/theme/` に変更。
- Shift+Enter / Alt+Shift+Enter を CSI-u (`\e[13;2u` / `\e[13;4u`) で送出し、
  TUI や tmux が Enter と区別できるようにした。
- ghostty: Hyprland 上の描画遅延対策で `async-backend = epoll`。
- kitty: グローバルバインドから cwd を引けるよう `listen_on` を設定。
