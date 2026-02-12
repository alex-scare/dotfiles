#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

focused_workspace="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

if [ -n "$focused_workspace" ]; then
    sketchybar --set "$NAME" label="$focused_workspace"
fi
