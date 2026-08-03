# AGENTS.md

This repo is for practical, personal dotfiles setup. Optimize for clarity and speed, not abstraction.

## Core Rules

- Do not overengineer. Prefer direct commands over helper functions when used once.
- Keep scripts small, readable, and linear.
- Add abstractions only when there is repeated logic (real duplication).
- Prefer explicit behavior over clever behavior.
- Use idempotent installs (`pacman -S --needed`, `yay -S --needed`).
- Fail fast (`set -euo pipefail`) in scripts.
- Keep changes minimal and scoped to the request.

## Script Conventions

- `install.sh` is the top-level orchestrator.
- `scripts/install-terminal.sh` owns terminal setup only.
- Use `sudo` only for system package/service operations (`pacman`, `systemctl`).
- Never run `yay` with `sudo`.
- Keep progress logs short and meaningful.
- Avoid interactive flows unless required.

## Dotfiles + Stow

- Use `stow --restow -t "$HOME" <package>` for managed folders.
- Prefer explicit `stow` calls over generic wrappers unless reused broadly.
- Keep package directories flat and obvious (`nvim`, `hyprland`, `ghostty`, `tmux`, `starship`).

## Theme and UX

- Terminal theme is controlled by Ghostty config.
- Prompt styling is controlled by Starship config.
- Keep font/theme decisions explicit in config files.
- Neovim colorschemes must be top-level Lazy plugin specs; nesting one inside another prevents Lazy from loading it. Name `catppuccin/nvim` explicitly as `catppuccin` to avoid its `nvim` name colliding with `nvim-treesitter/nvim`.
- Avoid catch-all AeroSpace `on-window-detected` tiling rules; they override dialog/minor-window heuristics and can break transient app UI.
- AeroSpace keybindings use `alt-h/j/k/l` for focus and `alt-shift-h/j/k/l` for moving windows.
- AeroSpace layout keybindings use `alt-n/m` for vertical/horizontal orientation and `alt-u/i` for shrink/grow.
- Keep AeroSpace container normalization enabled; prefer `layout horizontal/vertical` or `join-with` over `split`.
- AeroSpace workspaces 6-10 are assigned to the secondary monitor; workspace 10 uses `alt-0`.

## Editing Expectations

- Do not add unnecessary dependencies.
- Do not introduce framework-like structure into shell scripts.
- Preserve existing behavior unless the user asks to change it.
- Validate shell scripts after edits (`bash -n`).
