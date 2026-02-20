#!/usr/bin/env bash

set -euo pipefail

src_dir="/usr/share/applications"
dst_dir="$HOME/.local/share/applications"
entries=(
  "xgps.desktop"
  "xgpsspeed.desktop"
  "avahi-discover.desktop"
  "bssh.desktop"
  "bvnc.desktop"
  "rofi-theme-selector.desktop"
)

mkdir -p "$dst_dir"

for entry in "${entries[@]}"; do
  src="$src_dir/$entry"
  dst="$dst_dir/$entry"

  if [[ ! -f "$src" ]]; then
    echo "Skipping missing desktop entry: $entry"
    continue
  fi

  cp -f "$src" "$dst"
  sed -i '/^NoDisplay=/d;/^Hidden=/d' "$dst"
  printf '\nNoDisplay=true\n' >>"$dst"
done
