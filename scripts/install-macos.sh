#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is intended for macOS."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

echo "Installing macOS setup tools..."
brew install stow
brew install --cask zed brave-browser raycast localsend chatgpt

echo "Stowing Zed settings..."
stow --restow -t "$HOME" zed

if [[ -d "$SCRIPT_DIR/codex/.codex" ]]; then
  echo "Stowing Codex configuration..."
  stow --restow --ignore='\.DS_Store$' -t "$HOME" codex

  skill_source="$SCRIPT_DIR/codex/.codex/skills"
  skill_export="$HOME/Desktop/ChatGPT Skills"
  if [[ -d "$skill_source" ]]; then
    echo "Preparing ChatGPT skill uploads..."
    mkdir -p "$skill_export"
    for skill in "$skill_source"/*; do
      [[ -d "$skill" && -f "$skill/SKILL.md" ]] || continue
      skill_name="$(basename "$skill")"
      ditto -c -k --norsrc --keepParent "$skill" "$skill_export/$skill_name.zip"
    done
    echo "ChatGPT skill archives: $skill_export"
  fi
fi

if [[ -f "$SCRIPT_DIR/raycast/raycast.rayconfig" ]]; then
  cp -p "$SCRIPT_DIR/raycast/raycast.rayconfig" "$HOME/Desktop/Raycast.rayconfig"
  echo "Raycast export: $HOME/Desktop/Raycast.rayconfig"
fi

echo "Done. Open Raycast to import Raycast.rayconfig, if present."
echo "Open ChatGPT > Plugins > Skills > Create > Upload to add the skill archives."
