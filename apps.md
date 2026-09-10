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
- テキスト系 mime 型の既定アプリを Zed に統一(`configs/mimeapps.list`。text/plain に加え
  text/x-c、application/x-shellscript、application/xml 等の nvim.desktop 16 件を全置換)。
  従来の nvim.desktop は `Terminal=true` のため gio open でサイレント失敗する(固有の
  mime 型を持たないテキストが open で開けない問題の解消)
- `*.mdx` は freedesktop mime DB で `application/x-genesis-32x-rom` に誤マップされている
  (Genesis 32X ROM のダンプ形式と衝突)。`configs/local/share/mime/packages/text-mdx.xml`
  で `text/mdx` 型を上書き定義し、既定を Zed に設定
- `.md` も Zed(`text/markdown=dev.zed.Zed.desktop`)。従来は Typora だったが、テキスト処理を
  Zed に統一するため変更

## 5. FileBlade (data-goblin/fileblade)

IDE 風サイドバーの Omarchy プラグイン(0.1.x beta)。既定エディタ / mime 設定は §4。

- **導入**: `OMARCHY_SHELL_IPC_TIMEOUT=10s omarchy plugin add https://github.com/data-goblin/fileblade.git --enable --yes` + `omarchy restart shell`
- **拡張**: fileblade-skills / -memory / -hooks / -mcp も導入済み
- **キーバインド**: `configs/hypr/bindings.lua` の FileBlade ブロック(Super+B / Super+Shift+B / Super+Z ほか blade-aware 化)。
  `Super+W` は意図的に FileBlade 化していない(Chromium 確認付きクローズを維持)

### ローカルパッチ (`configs/omarchy/plugins/fileblade-search-restore.patch`)

`omarchy plugin update` で消えるため、更新後は再適用する:

```bash
git -C ~/.config/omarchy/plugins/data-goblin.fileblade apply \
  ~/Documents/workspace/ykc-omarchy-setup-kit/configs/omarchy/plugins/fileblade-search-restore.patch
omarchy restart shell
```

内容:
1. **検索復元**: 検索中にフォルダへ移動した後、Back/Forward(最初の 1 回のみ)で
   検索を復元して再実行する。Escape で検索をやめた後の通常ナビゲーションでは復元しない
2. **フォーカス時 IME 自動オフ**: ドック状態のブレードがフォーカスを取得した瞬間
   `fcitx5-remote -c` を実行。focus grab が compositor のキーボードフォーカスを持たないため、
   IME ON だと preedit/確定が直前のウィンドウ側に漏れる問題の回避

### 既知制限

- **ブレード内で日本語入力不可**: quickshell の layer surface に Wayland text-input
  フォーカスが来ない(quickshell/Hyprland レベルの問題)。上流報告ドラフトは
  `fileblade-ime-issue-draft.md`。日本語検索は `fileblade search "クエリ"` (ターミナルから)で可能
- `e`(Edit)の行ジャンプ指定(+N)は Zed CLI が vim 式 `+N` 非対応のため効かない
