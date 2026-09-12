# feedback: fcitx5 / Mozc の IME ON/OFF ホットキー反映

セットアップ時に「何も言わなくても」反映されるように、このブランチで
`fcitx5` / Mozc まわりの設定をキットへ取り込むためのまとめ。

## 背景 (なぜ必要か)

Quattro 既定では `変換` / `無変換` キーは fcitx5 のホットキーに含まれない。
このため **IME が非アクティブ (半角英数) のときはキーが Mozc に渡らず**、
`変換` を押しても日本語入力にならない。Mozc のカスタムキーマップだけでは解決できない
(fcitx5 のアクティベーション層で消費されないと IM に届かない)。

## 最終的な挙動

| キー | IME OFF 時 | IME ON 時 |
|---|---|---|
| `変換` (Henkan) | fcitx5 が有効化 → IME ON (ひらがな) | Mozc に渡り `CompositionModeHiragana` (ひらがな固定) |
| `無変換` (Muhenkan) | 何もしない (すでに英数) | fcitx5 が無効化 → IME OFF (半角英数) |

`Zenkaku_Hankaku` / `Ctrl+Space` のトグルは従来どおり残す。

仕組み:
- fcitx5 は **非アクティブ時のみ `ActivateKeys`** を、**アクティブ時のみ `DeactivateKeys`**
  を消費する (`InstancePrivate::canActivate` / `canDeactivate`)。
- アクティブ時に `変換` は `canActivate == false` なので IM に素通りし、Mozc 側で
  `CompositionModeHiragana` が効く。
- キー名 `Henkan`=0xFF23 / `Muhenkan`=0xFF22 は libxkbcommon で解決、`XKBLAYOUT=jp`。

## 反映すべき変更

### 1. `configs/fcitx5/config` (既存ファイルの更新)

```ini
[Hotkey/ActivateKeys]
0=Henkan

[Hotkey/DeactivateKeys]
0=Muhenkan
```

旧値 `0=<130>` / `0=Hangul_Hanja` は JIS 環境では未使用のため置換。

### 2. `configs/mozc/` (新規)

- `config1.db`: Mozc エンジン設定の完成品
  - `punctuation_method = COMMA_PERIOD` (`、` `。` → `，` `．`)
  - `space_character_form = FUNDAMENTAL_HALF_WIDTH` (スペース常に半角)
  - `session_keymap = CUSTOM` + `custom_keymap_table`
    - `Henkan` → `CompositionModeHiragana`
    - `Muhenkan` → `IMEOff` (fcitx5 をすり抜けた場合の保険)
- `config.txtpb` / `custom-keymap.tsv`: 設定のソース (可読)
- `install.sh`: 配置 (fcitx5 を止めてから差し替え)
- `generate.sh`: `protoc` で再生成 (Mozc 3.34.6239 の proto を取得)
- `README.md`: 設定内容と手順

### 3. `README.md` (マッピング表)

`configs/mozc/` の配置先を追記:

```
| `configs/mozc/config1.db` | `~/.config/mozc/config1.db` (`configs/mozc/install.sh`、fcitx5 停止が必要) |
```

### 4. `system-notes.md` (2章 IME)

「変換=IME ON (ひらがな) / 無変換=IME OFF (英数)」の実装方法と、
`config1.db` は Mozc 終了時に上書きされる注意を追記。

## セットアップ手順 (反映後)

1. `configs/fcitx5/config` を `~/.config/fcitx5/config` に配置
2. `configs/mozc/install.sh` を実行 (`config1.db` を配置 + fcitx5 再起動)
3. 必要に応じて `configs/fcitx5/conf/mozc.conf` (`InitialMode=Hiragana`) を配置

## 検証

1. 半角英数の状態で `変換` → ひらがな入力になる
2. 入力中に `無変換` → 半角英数になる
3. 再度 `変換` → ひらがなに戻る
4. `,` `.` の入力が `，` `．` になる
5. 挿入スペースが半角になる

## 補足

- 既存の `config1.db` は `install.sh` が `config1.db.bak.<timestamp>` に退避する。
- `config1.db` は Mozc / protobuf のバージョンに依存する。`fcitx5-mozc` が
  3.34.6239.x から外れたら `generate.sh` で作り直す。
