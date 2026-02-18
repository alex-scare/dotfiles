#!/bin/sh

CONNECTED_COUNT="$(
  system_profiler SPBluetoothDataType 2>/dev/null | awk '
    /^[[:space:]]+[^:][^:]*:$/ {
      section=$0
      sub(/^[[:space:]]+/, "", section)
      sub(/:$/, "", section)
    }
    /Connected:[[:space:]]+Yes/ {
      if (section != "" &&
          section != "Bluetooth" &&
          section != "Devices" &&
          section != "Devices (Paired, Configured, etc.)" &&
          section != "Hardware, Features, and Settings") {
        if (!seen[section]++) {
          count++
        }
      }
    }
    END {
      printf "%d", count
    }
  '
)"

if [ -z "$CONNECTED_COUNT" ]; then
  CONNECTED_COUNT=0
fi

if [ "$CONNECTED_COUNT" -gt 0 ] 2>/dev/null; then
  sketchybar --set "$NAME" drawing=on icon="󰂱" label="[$CONNECTED_COUNT]"
  exit 0
fi

sketchybar --set "$NAME" drawing=on icon="󰂲" label="[0]"
