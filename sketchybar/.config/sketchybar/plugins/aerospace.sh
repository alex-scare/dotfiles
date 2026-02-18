#!/usr/bin/env bash

# Prefer explicit workspace env var from AeroSpace callback.
focused_workspace="$FOCUSED_WORKSPACE"

# Some SketchyBar events send structured payloads in INFO (e.g. JSON-like),
# so only trust INFO when it looks like a simple workspace name.
if [ -z "$focused_workspace" ] && [ -n "$INFO" ]; then
  if printf '%s' "$INFO" | grep -Eq '^[[:alnum:]_-]+$'; then
    focused_workspace="$INFO"
  fi
fi

# Fallback to querying AeroSpace directly.
if [ -z "$focused_workspace" ]; then
  focused_workspace="$(aerospace list-workspaces --focused 2>/dev/null | head -n 1)"
fi

if [ -n "$focused_workspace" ]; then
  sketchybar --set "$NAME" label="$focused_workspace"
fi
