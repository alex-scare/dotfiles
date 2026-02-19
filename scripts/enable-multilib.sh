#!/usr/bin/env bash

set -euo pipefail

PACMAN_CONF="/etc/pacman.conf"

if grep -Eq '^[[:space:]]*\[multilib\]' "$PACMAN_CONF"; then
  echo "multilib already enabled, skipping."
  exit 0
fi

if grep -Eq '^[[:space:]]*#[[:space:]]*\[multilib\]' "$PACMAN_CONF"; then
  echo "Enabling multilib in /etc/pacman.conf..."
  sudo sed -i \
    '/^[[:space:]]*#[[:space:]]*\[multilib\]/,/^[[:space:]]*#[[:space:]]*Include[[:space:]]*=[[:space:]]*\/etc\/pacman\.d\/mirrorlist/s/^[[:space:]]*#[[:space:]]*//' \
    "$PACMAN_CONF"
else
  echo "Adding multilib section to /etc/pacman.conf..."
  printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' | sudo tee -a "$PACMAN_CONF" >/dev/null
fi

echo "Refreshing pacman package databases..."
sudo pacman -Sy --noconfirm
