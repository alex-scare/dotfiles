#!/bin/sh

get_current_volume() {
  if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
    printf '%s' "$INFO"
    return
  fi

  osascript -e 'output volume of (get volume settings)' 2>/dev/null | tr -dc '0-9'
}

get_default_output_device() {
  system_profiler SPAudioDataType 2>/dev/null | awk '
    /^[[:space:]]+[^:][^:]*:$/ {
      section=$0
      sub(/^[[:space:]]+/, "", section)
      sub(/:$/, "", section)
    }
    /Default Output Device:[[:space:]]+Yes/ {
      if (section != "" &&
          section != "Audio" &&
          section != "Devices") {
        print section
        exit
      }
    }
  '
}

device_icon() {
  device_lc="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  volume="$2"

  if [ "$volume" -eq 0 ] 2>/dev/null; then
    printf '󰖁'
    return
  fi

  case "$device_lc" in
    *airpods*|*headphones*|*headset*|*earbuds*|*buds*|*beats*|*bose*|*sony*)
      printf '󰋋'
      ;;
    *hdmi*|*display*|*monitor*|*tv*)
      printf '󰍹'
      ;;
    *speaker*|*macbook*|*internal*|*built-in*)
      printf '󰓃'
      ;;
    *bluetooth*)
      printf '󰂯'
      ;;
    *)
      printf '󰕾'
      ;;
  esac
}

VOLUME="$(get_current_volume)"
[ -z "$VOLUME" ] && VOLUME=0

OUTPUT_DEVICE="$(get_default_output_device)"
ICON="$(device_icon "$OUTPUT_DEVICE" "$VOLUME")"

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
