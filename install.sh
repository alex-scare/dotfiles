#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This script is intended for Arch Linux."
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "Run this script as your normal user (it will use sudo when needed)."
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

step() {
  echo
  echo "$1"
}

i_pacman() {
  sudo pacman -S --needed --noconfirm "$@"
}

i_yay() {
  yay -S --needed --noconfirm "$@"
}

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    echo "yay already installed, skipping bootstrap."
    return
  fi

  echo "Installing yay from AUR..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
  )
  rm -rf "$tmpdir"
}

install_jetbrains_nerd_font() {
  if pacman -Qi ttf-jetbrains-mono-nerd >/dev/null 2>&1; then
    echo "JetBrains Nerd Font already installed, skipping."
    return
  fi

  echo "Installing JetBrains Nerd Font..."
  i_pacman ttf-jetbrains-mono-nerd
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

stow_package() {
  local pkg="$1"

  if [[ -d "$pkg" ]]; then
    stow --restow -t "$HOME" "$pkg"
    return
  fi

  echo "Skipping stow for '$pkg' (directory not found)."
}

##### Basic functionality

step "Installing base packages"
i_pacman wget base-devel stow git

step "Installing yay (AUR helper)"
install_yay

##### Prepare terminal

step "Installing terminal tools"
i_pacman ghostty neovim zsh

step "Installing JetBrains Nerd Font"
install_jetbrains_nerd_font

step "Setting default shell to zsh"
set_default_shell

step "Stowing terminal/editor dotfiles"
stow_package nvim
stow_package ghostty
stow_package tmux

##### Prepare hyprland

step "Installing Hyprland packages"
i_pacman hyprland hyprpaper waybar

step "Stowing Hyprland dotfiles"
stow_package hyprland

##### Fix nvidia drivers 

step "Installing NVIDIA-related packages"
i_pacman nvidia-settings nvidia-utils nvidia-open-dkms gamemode linux-headers

##### Install useful stuff

step "Installing extra apps"
i_pacman proton-vpn-gtk-app
i_yay brave-bin

echo
echo "Done."
