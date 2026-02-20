#!/usr/bin/env bash
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
cache_file="$cache_dir/waybar-location"
ts_file="$cache_dir/waybar-location-ts"
mkdir -p "$cache_dir"

fetch_location() {
  local json city cc out
  json="$(curl -fsS --max-time 0.8 https://ipapi.co/json/ 2>/dev/null || true)"
  [[ -z "$json" ]] && return 1

  city="$(printf '%s' "$json" | sed -n 's/.*"city"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  cc="$(printf '%s' "$json" | sed -n 's/.*"country_code"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

  [[ -z "$city" || -z "$cc" ]] && return 1
  out="$city, $cc"
  printf '%s\n' "$out" > "$cache_file"
  date +%s > "$ts_file"
  return 0
}

now="$(date +%s)"
last=0
if [[ -f "$ts_file" ]]; then
  last="$(cat "$ts_file" 2>/dev/null || echo 0)"
fi

if (( now - last >= 300 )); then
  fetch_location || true
fi

if [[ -f "$cache_file" ]]; then
  cat "$cache_file"
else
  echo "Location"
fi
