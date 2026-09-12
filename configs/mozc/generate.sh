#!/bin/bash
# Regenerate config1.db from config.txtpb using Mozc's config.proto.
#
# The proto is pinned to the Mozc release that ships with fcitx5-mozc
# 3.34.6239.2 (Arch). Update MOZC_TAG when the packaged Mozc version changes.
#
# Requires: protoc (extra/protobuf) and curl.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOZC_TAG="${MOZC_TAG:-3.34.6239}"
proto="$here/config.proto"

if [ ! -f "$proto" ]; then
  curl -fsSL \
    "https://raw.githubusercontent.com/google/mozc/${MOZC_TAG}/src/protocol/config.proto" \
    -o "$proto"
fi

protoc --encode=mozc.config.Config --proto_path="$here" "$proto" \
  < "$here/config.txtpb" > "$here/config1.db"
echo "Generated $here/config1.db"
