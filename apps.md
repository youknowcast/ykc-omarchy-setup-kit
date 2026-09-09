# 3rd Party アプリメモ

Omarchy 環境で利用している 3rd party アプリのインストール・運用メモです。

## 1. 必須ツール
セットアップ時に追加インストールが必要なもの：

- `fzf` (window-switcher / nvim-cheats)
- `jq` (window-switcher)
- `wl-clipboard` (緊急日本語入力)
- Ruby + `gtk3` gem (緊急日本語入力)

導入は `omarchy pkg add <pkg>` (AUR のみのものは `omarchy pkg aur add <pkg>`)。

## 2. インストール済みアプリケーション

- Ghostty (Terminal)
- Obsidian
- Typora
- 1Password
- Chromium (Web Apps用)

## 3. JetBrains Toolbox

- **用途**: JetBrains IDE の管理
- **実行体の配置**: `~/.local/share/JetBrains/bin` 配下にダウンロードした実行体を配置
- **注意**: 2026.1 以降のネイティブ Wayland 版では Shift 2度押しの Search Everywhere が
  Omarchy 既定の `kb_options` と衝突する。対処は system-notes.md の `input.lua` の項を参照。

## 4. 既定エディタ / mime 設定

- 既定エディタ: `~/.local/state/omarchy/defaults/editor` = `zeditor`(nvim → Zed に変更)。
  `omarchy-launch-editor` が参照する。vim 式 `+N` 行指定は Zed CLI 非対応のため効かない
- `text/plain` 既定アプリ → Zed(`configs/mimeapps.list`)。
  従来の nvim.desktop は `Terminal=true` のため gio open でサイレント失敗する(固有の
  mime 型を持たないテキストが open で開けない問題の解消)
- `*.mdx` は freedesktop mime DB で `application/x-genesis-32x-rom` に誤マップされている
  (Genesis 32X ROM のダンプ形式と衝突)。`configs/local/share/mime/packages/text-mdx.xml`
  で `text/mdx` 型を上書き定義し、既定を Zed に設定
- `.md` は Typora のまま(text/markdown は未変更)
