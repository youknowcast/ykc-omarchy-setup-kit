# Mozc engine config (`~/.config/mozc/config1.db`)

fcitx5 の日本語入力エンジン (Mozc) の設定。`~/.config/mozc/config1.db` は
`mozc::config::Config` protobuf で、**既定値から変更した差分ではなく完全な設定**として
置いている (Mozc はファイルが無い/壊れている場合 proto 既定値で動くが、
`character_form_rules` などの一部既定値はここにしか無いため)。

## 設定内容

| フィールド | 値 | 効果 |
|---|---|---|
| `punctuation_method` | `COMMA_PERIOD` | `,` `.` の入力が `，` `．` になる (既定は `、` `。`) |
| `space_character_form` | `FUNDAMENTAL_HALF_WIDTH` | 挿入されるスペースが常に半角 |
| `session_keymap` | `CUSTOM` | `custom_keymap_table` を使用 |
| `custom_keymap_table` | ms-ime ベース + 変更 | 下記 |

カスタムキーマップ (ms-ime.tsv からの差分):

| 状態 | キー | 既定 | 変更後 |
|---|---|---|---|
| `DirectInput` | `Henkan` | `Reconvert` | `CompositionModeHiragana` |
| `Precomposition` | `Henkan` | `Reconvert` | `CompositionModeHiragana` |
| `Composition` | `Henkan` | `Convert` | `CompositionModeHiragana` |
| `Conversion` | `Henkan` | `ConvertNext` | `CompositionModeHiragana` |
| `Precomposition` | `Muhenkan` | `CompositionModeSwitchKanaType` | `IMEOff` |
| `Composition` | `Muhenkan` | `SwitchKanaType` | `IMEOff` |
| `Conversion` | `Muhenkan` | `SwitchKanaType` | `IMEOff` |

`Shift + 変換` / `Shift + 無変換` は既定のまま。

## 配置

```bash
./install.sh
```

`install.sh` は念のため fcitx5 / mozc_server を停止してから `config1.db` を差し替える。
**Mozc は終了時に `config1.db` を上書きする**ので、起動中にファイルを置いても効かない
(このリポジトリの初回セットアップ時に踏んだ)。

## 再生成

```bash
./generate.sh
```

`config.txtpb` (テキスト proto) から `protoc --encode` で `config1.db` を作る。
`config.proto` は同梱しないので、初回は Mozc 3.34.6239 のタグから取得する
(`fcitx5-mozc 3.34.6239.2` に対応)。Mozc のバージョンが上がったら `MOZC_TAG` を更新:

```bash
MOZC_TAG=3.xx.yyyy ./generate.sh
```

`custom-keymap.tsv` は可読性のための元データ (ms-ime ベースに上表の変更を適用したもの)。
`config.txtpb` の `custom_keymap_table` にエスケープして埋め込んであるため、
`generate.sh` だけでは再生成に使われない。キーマップを変えるときは
`custom-keymap.tsv` を編集し、`config.txtpb` の該当文字列を作り直すこと。

## ファイル

| ファイル | 内容 |
|---|---|
| `config1.db` | 完成品 (配置用) |
| `config.txtpb` | 設定のソース (text proto) |
| `custom-keymap.tsv` | カスタムキーマップ (可読用) |
| `install.sh` | 配置スクリプト |
| `generate.sh` | `config1.db` 再生成スクリプト |
