#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
source "$SCRIPT_DIR/scripts/lib/os.sh"

if ! isArch; then
  echo "This script is intended for Arch Linux."
  exit 1
fi

if [[ $EUID -eq 0 ]]; then
  echo "Run this script as your normal user (it will use sudo when needed)."
  exit 1
fi

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

step "Enabling multilib repository"
bash "$SCRIPT_DIR/scripts/enable-multilib.sh"

step "Installing base packages"
i_pacman wget base-devel stow git

step "Installing yay (AUR helper)"
install_yay

step "Running terminal setup"
bash "$SCRIPT_DIR/scripts/install-terminal.sh"

##### Prepare hyprland

step "Installing Hyprland packages"
i_pacman hyprland hyprpaper waybar rofi

step "Stowing Hyprland dotfiles"
stow --restow -t "$HOME" hyprland
stow --restow -t "$HOME" hyprpaper
stow --restow -t "$HOME" waybar
stow --restow -t "$HOME" backgrounds
stow --restow -t "$HOME" rofi

##### Fix nvidia drivers 

step "Installing NVIDIA-related packages"
i_pacman nvidia-settings nvidia-utils nvidia-open-dkms gamemode linux-headers lib32-nvidia-utils egl-wayland

step "Rebuilding initramfs"
sudo mkinitcpio -P

##### Install steam

step "Installing Steam"
i_pacman steam

##### Install useful stuff

step "Installing extra apps"
i_pacman proton-vpn-gtk-app
yay -S --needed --noconfirm brave-bin

echo
echo "Done."
