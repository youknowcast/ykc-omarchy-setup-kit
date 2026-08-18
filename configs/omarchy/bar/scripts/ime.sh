#!/bin/sh

# fcitx5-remote without options prints the input method state:
# 0 = closed, 1 = inactive (latin), 2 = active (Japanese)
if fcitx5-remote --check >/dev/null 2>&1 && [ "$(fcitx5-remote)" = "2" ]; then
  echo "あ"
else
  echo "EN"
fi
