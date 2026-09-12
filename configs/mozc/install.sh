#!/bin/bash
# Install the Mozc engine config (config1.db) used by the ykc IME setup.
#
# Applied settings (see config.txtpb / custom-keymap.tsv):
#   - punctuation_method      = COMMA_PERIOD            (, . -> ， ．)
#   - space_character_form    = FUNDAMENTAL_HALF_WIDTH  (space is always half-width)
#   - session_keymap          = CUSTOM
#   - Henkan   -> CompositionModeHiragana
#   - Muhenkan -> IMEOff
#
# fcitx5 (and its child mozc_server) rewrites config1.db on exit, so it MUST be
# stopped before replacing the file. configs/fcitx5/config supplies the matching
# global hotkeys (ActivateKeys=Henkan / DeactivateKeys=Muhenkan).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="$HOME/.config/mozc/config1.db"

mkdir -p "$(dirname "$target")"

if [ -f "$target" ]; then
  cp -a "$target" "$target.bak.$(date +%Y%m%d-%H%M%S)"
  echo "Backed up existing config1.db"
fi

systemctl --user stop omarchy-fcitx5.service 2>/dev/null || true
pkill -x fcitx5 2>/dev/null || true
sleep 1
pkill -x mozc_server 2>/dev/null || true
sleep 1

install -m 600 "$here/config1.db" "$target"
echo "Installed $target"

systemctl --user start omarchy-fcitx5.service 2>/dev/null || true
echo "Restarted fcitx5"
