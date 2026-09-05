# Keychron Nape Pro — レイヤー切替ハングの回避策

## 問題

Nape Pro はレイヤー切替 (`MO(n)` / `TO(n)` 等) のたびに、Launcher 用ベンダーインターフェース
(HID usage page `0xFF60`) へ 32 バイトの通知を送信する。ホストがこの通知を読みに行かないと
ファームウェアが送信完了待ちで永久ブロックし、**全 HID インターフェースが死ぬ**。

- Mac では Launcher (WebHID) が常時読み取るため発生しない。
- Linux では Launcher が接続できない環境が多く、誰も読まないため発生する。
- 復帰は物理的な USB 抜き差しのみ。

## 回避策

ベンダーインターフェース (`/dev/hidraw*`) を常時読み取る daemon を systemd で動かす。

### 構成

- `90-nape-pro.rules` → `/etc/udev/rules.d/90-nape-pro.rules`
  - VID:PID `3434:0440` の interface 1/2 の hidraw を安定名で公開:
    - interface 1 (vendor, `0xFF60`) → `/dev/nape-pro-vendor`
    - interface 2 (DoH, `0x8C`) → `/dev/nape-pro-doh`
- `nape-pro-reader.sh` → `/usr/local/bin/nape-pro-reader.sh`
- `nape-pro-reader.service` → `/etc/systemd/system/nape-pro-reader.service`

### インストール

```bash
sudo install -Dm644 configs/nape-pro/90-nape-pro.rules /etc/udev/rules.d/90-nape-pro.rules
sudo install -Dm755 configs/nape-pro/nape-pro-reader.sh /usr/local/bin/nape-pro-reader.sh
sudo install -Dm644 configs/nape-pro/nape-pro-reader.service /etc/systemd/system/nape-pro-reader.service
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl daemon-reload
sudo systemctl enable --now nape-pro-reader.service
```

### 確認

```bash
ls -l /dev/nape-pro-vendor /dev/nape-pro-doh   # symlink が存在する
systemctl status nape-pro-reader.service         # active
```

レイヤー切替 (MO/TO) を押してもハングしなくなる。

## 参考: 検証で得た通知フォーマット

レイヤー切替時に hidraw5 (vendor) から受信する 32 バイトレポート (先頭のみ):

```
a3 02 06 02 00 ...   # レイヤー 2 へ切替
a3 01 06 02 00 ...   # レイヤー 1 へ切替
```

## 留意点

- デバイス側の根本修正 (通知をブロッキング送信しない等) は Keychron のファームウェア更新待ち。
- 本回避策は読み取り専用で、Launcher の設定機能 (書き込み) には影響しない。