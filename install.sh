#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This script is intended for Arch Linux."
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found. This script is intended for Arch Linux."
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

##### Basic functionality

step "Installing base packages"
i_pacman wget base-devel stow git

step "Installing yay (AUR helper)"
install_yay

step "Running terminal setup"
bash "$SCRIPT_DIR/scripts/install-terminal.sh"

##### Prepare hyprland

step "Installing Hyprland packages"
i_pacman hyprland hyprpaper waybar

step "Stowing Hyprland dotfiles"
stow --restow -t "$HOME" hyprland

##### Fix nvidia drivers 

step "Installing NVIDIA-related packages"
i_pacman nvidia-settings nvidia-utils nvidia-open-dkms gamemode linux-headers

##### Install useful stuff

step "Installing extra apps"
i_pacman proton-vpn-gtk-app
yay -S --needed --noconfirm brave-bin

echo
echo "Done."
