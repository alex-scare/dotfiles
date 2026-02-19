#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
source "$ROOT_DIR/scripts/lib/os.sh"

if ! isArch; then
  echo "This script is intended for Arch Linux."
  exit 1
fi

step() {
  echo
  echo "$1"
}

set_default_shell() {
  local current_shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"

  if [[ "$current_shell" == "/usr/bin/zsh" ]]; then
    echo "Default shell is already /usr/bin/zsh, skipping."
    return
  fi

  chsh -s /usr/bin/zsh
}

step "Installing terminal tools and font"
sudo pacman -S --needed --noconfirm ghostty neovim zsh stow ttf-jetbrains-mono-nerd

step "Installing starship"
yay -S --needed --noconfirm starship

step "Setting default shell to zsh"
set_default_shell

step "Stowing terminal/editor dotfiles"
stow --restow -t "$HOME" nvim
stow --restow -t "$HOME" ghostty
stow --restow -t "$HOME" starship
stow --restow -t "$HOME" tmux
stow --restow -t "$HOME" zsh

echo
echo "Terminal setup done."
