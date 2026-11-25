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
- **Omarchy shell**: バー配置 (`shell.json`)、IME 表示用の自作ウィジェット、ワークスペース名表示プラグイン、Ledge (ファイル一時置き場)、Orca items / asumi 進捗ウィジェット。
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
| `configs/omarchy/bar/scripts/orca-items*.sh` | `~/.config/omarchy/bar/scripts/` (755。`scripts/install-orca-items.sh` でも導入可) |
| `configs/omarchy/plugins/youknow.workspaces/` | `~/.config/omarchy/plugins/youknow.workspaces/` |
| `configs/omarchy/plugins/bylund.ledge/` | `~/.config/omarchy/plugins/bylund.ledge/` (Ledge: `omarchy plugin add https://github.com/andreas-bylund/omarchy-ledge.git`) |
| `configs/omarchy/branding/` | `~/.config/omarchy/branding/` |
| `configs/alacritty/`, `configs/kitty/`, `configs/ghostty/`, `configs/chromium-flags.conf`, `configs/vivaldi-stable.conf` | `~/.config/` 直下の同名パス |
| `configs/Cursor/` | `~/.config/` 直下の同名パス |
| `configs/fcitx5/` | `~/.config/fcitx5/` |
| `configs/local/share/applications/*.desktop` | `~/.local/share/applications/` |
| `configs/local/share/mime/packages/text-mdx.xml` | `~/.local/share/mime/packages/` (適用後 `update-mime-database ~/.local/share/mime`) |
| `configs/mimeapps.list` | `~/.config/mimeapps.list` |
| `configs/git/config`, `configs/git/ignore` | `~/.config/git/` (git のエディタは terminal の vim、`EDITOR` は Zed のまま) |
| `configs/keyd/default.conf` | `/etc/keyd/default.conf` (要 root) |
| `configs/nape-pro/90-nape-pro.rules` | `/etc/udev/rules.d/90-nape-pro.rules` (要 root) |
| `configs/nape-pro/nape-pro-reader.sh` | `/usr/local/bin/nape-pro-reader.sh` (要 root) |
| `configs/nape-pro/nape-pro-reader.service` | `/etc/systemd/system/nape-pro-reader.service` (要 root) |

## Orca items ウィジェット

Orca の `Needs you` 件数と asumi の進捗をバーに表示する command 型ウィジェット。

### 導入

```sh
# 変更内容の確認 (何も書き込まない)
./scripts/install-orca-items.sh --dry-run

# 実行
./scripts/install-orca-items.sh
```

- `configs/omarchy/bar/scripts/orca-items*.sh` を `~/.config/omarchy/bar/scripts/` に mode 755 で配置する。
- `~/.config/omarchy/shell.json` の `bar.layout.right` に `orca.items` を追加する。既存の
  `orca.items` は設定を置換し、重複していれば 1 つにまとめる。それ以外のバー設定・ウィジェットは変更しない。
- 実際に変更したときだけ `shell.json.bak.YYYYmmdd-HHMMSS` を作る (変更が無ければ何も書かない)。
- `--prefix DIR` で `$HOME` 以外のツリーに導入できる (テスト用。既定は `$HOME`)。
- 手動で入れる場合は 3 スクリプトを `~/.config/omarchy/bar/scripts/` にコピーして
  `chmod 755` し、`shell.json` に下記エントリを足す:

```json
{
  "id": "orca.items",
  "type": "command",
  "exec": "~/.config/omarchy/bar/scripts/orca-items.sh",
  "interval": 30,
  "tooltip": "Orca items",
  "onClick": "~/.config/omarchy/bar/scripts/orca-items-menu.sh",
  "onRightClick": "~/.config/omarchy/bar/scripts/orca-items-menu.sh --all",
  "onMiddleClick": "~/.config/omarchy/bar/scripts/orca-items-copy.sh"
}
```

### 表示と操作

| 操作 | 動作 |
|---|---|
| 表示 | `󰚩 N` (全 bot の `needs_you` 合計)。asumi が attention 中は `󰚩 N ◆` |
| ホバー | 先頭に asumi の headline / lines 先頭 6 件 / updated、続けて `Needs you N / In progress M` と Needs you の先頭 6 件 (bot 名 + タイトル) |
| 左クリック | 先頭に `asumi の進捗 · <headline>`、続けて Needs you の item 一覧を `omarchy menu select` で表示 |
| 右クリック | 同じ一覧を全 open item (status 付き) で表示 |
| 中クリック | 表示中のテキストと tooltip を `wl-copy` でコピーし `notify-send` |

- 一覧から item を選ぶと `stably-orca orca://bot/<bot-id>` でその bot を Orca で開く。
  **item カード自体は開けない** ため、対象の item は Orca 側で bot を開いてから選ぶ。
- Orca 未起動・`orca` CLI 無し・サインイン切れの場合は `󰚩 ?` と tooltip に理由を出すだけで、
  バーや他のウィジェットは壊れない。一度成功した後は `$XDG_RUNTIME_DIR/orca-items/state.json`
  の直前値を `!` 付きで残す。
- 更新間隔は 30 秒。Orca 側の item は最大 8 秒でタイムアウトする。

### asumi の進捗

asumi が見回りのたびに更新する `~/.local/state/asumi/progress.json` があれば、バーとメニューの先頭に
その進捗を表示する。

```json
{"updated":"ISO 時刻","headline":"…","attention":true,"lines":["…"]}
```

- `attention` が `true` のときだけバーの `text` 末尾に `◆` を付ける。`class` は `needs_you > 0`
  または attention のとき `active` になる。
- ツールチップは `asumi: <headline>`、`lines` の先頭 6 件、`updated` の順に出す。その後ろに従来の
  `Needs you / In progress` と item 一覧が続く。
- 左クリック / 右クリックの一覧は先頭が `asumi の進捗 · <headline>` になり、選ぶと
  `stably-orca orca://bot/a374f8a2-829d-4c20-83b0-7076f0d26077` で asumi の Home chat を開く。
  ここから item カードを直接開くことはできない。
- 文字列はタブ・改行を空白に潰し、headline と各 line を 60 文字で切る (行は先頭 6 件)。
- `progress.json` が無い・JSON が壊れている・`headline` が空のときは asumi 部分を出さず、
  `󰚩 N` と item 一覧だけの従来動作になる。Orca が止まっている場合の `󰚩 ?` もそのまま。
- テストなどで場所を変えるときは `ASUMI_PROGRESS_FILE` で上書きできる。

### 依存

| 依存 | 用途 |
|---|---|
| Orca デスクトップアプリ (`stably-orca-bin`) | 起動中であること。`orca status` で確認 |
| `orca` CLI (アプリ同梱の `~/.config/orca/linux-orca-cli-shim/orca`) | `orca status` / `orca bot list` / `orca bot item list`。サインインが必要 |
| `jq` | JSON の解析 (必須) |
| `bash` | スクリプトの実行 (必須) |
| `omarchy` (`omarchy menu select` / `omarchy-menu-select`) | クリック時の一覧表示 |
| `stably-orca` | 一覧から選んだ bot を開く |
| `wl-clipboard` (`wl-copy`) | 中クリックのコピー |
| `libnotify` (`notify-send`) | 中クリックの通知 |

`install-orca-items.sh` は `jq` と `bash` が無ければ中断し、それ以外が無ければ警告だけ出して続行する。

## Documentation

- [system-notes.md](./system-notes.md): OS 設定・構築ノート
- [apps.md](./apps.md): 3rd party アプリの導入・運用メモ
