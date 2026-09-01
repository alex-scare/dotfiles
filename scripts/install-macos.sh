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

echo "Installing command-line tools..."
brew install stow git gh neovim tmux starship fzf tree bat

echo "Installing macOS apps..."
brew tap nikitabobko/tap
brew trust nikitabobko/tap
brew install --cask nikitabobko/tap/aerospace
brew install --cask zed brave-browser localsend ghostty \
  font-jetbrains-mono-nerd-font
brew install --cask "$SCRIPT_DIR/raycast/raycast-v1.rb"

echo "Stowing macOS dotfiles..."
stow --restow -t "$HOME" aerospace
stow --restow -t "$HOME" backgrounds
stow --restow -t "$HOME" ghostty
stow --restow -t "$HOME" nvim
stow --restow -t "$HOME" starship
stow --restow -t "$HOME" tmux
stow --restow -t "$HOME" zsh
stow --restow -t "$HOME" zed

echo "Installing tmux plugins..."
mkdir -p "$HOME/.tmux/plugins"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

if [[ -d "$SCRIPT_DIR/codex/.codex" ]]; then
  echo "Stowing Codex configuration..."
  stow --restow --ignore='\.DS_Store$' -t "$HOME" codex
fi

if [[ -f "$SCRIPT_DIR/raycast/raycast.rayconfig" ]]; then
  cp -p "$SCRIPT_DIR/raycast/raycast.rayconfig" "$HOME/Desktop/Raycast.rayconfig"
  echo "Raycast export: $HOME/Desktop/Raycast.rayconfig"
fi

echo "Done. Open Raycast to import Raycast.rayconfig, if present."
