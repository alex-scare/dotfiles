#!/bin/sh

LAYOUT_ID="$(defaults read com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null)"

if [ -n "$LAYOUT_ID" ]; then
  LAYOUT="${LAYOUT_ID##*.}"
else
  LAYOUT="$(defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null | awk -F'"' '/"KeyboardLayout Name"/ {print $4; exit}')"
fi

[ -z "$LAYOUT" ] && LAYOUT="N/A"

case "$LAYOUT" in
  Russian*|ru*|RU*) LAYOUT="RU" ;;
  U.S.*|US|ABC) LAYOUT="US" ;;
esac

sketchybar --set "$NAME" label="$LAYOUT"
