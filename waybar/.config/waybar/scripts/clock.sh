#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-clock-mode"

if [[ "${1:-}" == "--toggle" ]]; then
  mode="minimal"
  if [[ -f "$state_file" ]]; then
    mode="$(<"$state_file")"
  fi

  if [[ "$mode" == "minimal" ]]; then
    printf '%s\n' "informative" > "$state_file"
  else
    printf '%s\n' "minimal" > "$state_file"
  fi
  exit 0
fi

mode="minimal"
if [[ -f "$state_file" ]]; then
  mode="$(<"$state_file")"
fi

if [[ "$mode" == "informative" ]]; then
  date '+%a %d.%b %-I:%M'
else
  date '+%a %-I:%M'
fi
