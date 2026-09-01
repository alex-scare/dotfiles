## Using GNU Stow

Run Stow from the repository root. Each top-level directory is a package whose
contents are linked into your home directory.

```sh
# Install or refresh a package
stow --restow -t "$HOME" zsh

# Preview changes without applying them
stow --no --verbose --restow -t "$HOME" zsh

# Remove a package's links
stow --delete -t "$HOME" zsh
```

Replace `zsh` with the package you want to manage, such as `nvim`, `tmux`,
`ghostty`, or `starship`.

#### About configuration files 

- Common configs: `zsh`, `tmux`, `ghostty`, `starship`, `nvim`
- Arch only: `hyprland`, `waybar`
- MacOS only: `aerospace`

#### AeroSpace window layout

AeroSpace keeps each workspace as a tree of containers. Horizontal means windows
sit left/right inside the current container; vertical means they sit up/down.

- `alt-h/j/k/l` moves focus left/down/up/right.
- `alt-shift-h/j/k/l` moves the focused window left/down/up/right.
- `alt-n` makes the focused tiled container vertical, so windows stack up/down.
- `alt-m` makes the focused tiled container horizontal, so windows sit left/right.
- `alt-u/i` shrinks or grows the focused window with smart resize.
- `alt-/` cycles the focused container through tiled horizontal/vertical layouts.

For more deliberate nesting, enter service mode with `alt-shift-;`, then use
`alt-shift-h/j/k/l` to join the focused window with its neighbor in that
direction.

For a common three-window layout with one window on the left half and two
windows stacked on the right half:

1. Put the three windows on the same workspace.
2. Focus the window that should stay on the left.
3. Use `alt-shift-h` or `alt-shift-l` until it is on the left side.
4. Focus the middle/right window that should be stacked with its neighbor.
5. Enter service mode with `alt-shift-;`.
6. Press `alt-shift-l` to join it with the window to the right, or
   `alt-shift-h` to join it with the window to the left.
7. Press `alt-n` to make that joined right-side container vertical.
8. Use `alt-u/i` on the focused window if the split needs a size adjustment.

#### SketchyBar integration

SketchyBar is not part of the active macOS setup anymore, but the dormant
`sketchybar/` package is still in the repo.

To restore it, stow the package with `stow --restow -t "$HOME" sketchybar`,
start SketchyBar through your macOS service manager, then add this AeroSpace
workspace hook back to `aerospace/.aerospace.toml`:

```toml
exec-on-workspace-change = ['/bin/bash', '-c',
    'pgrep -x sketchybar >/dev/null && sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```

If the bar sits at the top of the screen, set `gaps.outer.top` to the bar height
in the AeroSpace `[gaps]` section.

#### About installation on Arch

Installation script is supposed to run only on Arch. 

1. Connect to wifi via networkmanager 

Package should be selected as additional package during the installation

```
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
nmcli device wifi connect "name" password "pass"
```

2. Make script executable

```
chmod +x install.sh
```

3. Execute

#### About installation on macOS

Run the same top-level installer from a clone of this repository:

```sh
chmod +x install.sh
./install.sh
```

It installs Homebrew when needed, then installs AeroSpace, Zed, Brave,
LocalSend, Ghostty, Neovim, tmux, Starship, the JetBrains Mono Nerd Font, and
the shell tools used by the configurations. It stows the macOS-compatible
packages: `aerospace`, `backgrounds`, `ghostty`, `nvim`, `starship`, `tmux`,
`zsh`, and `zed`.

It deliberately does not install or stow `sketchybar`: that package remains
dormant, as described above. The script also installs TPM and its tmux plugins.
The tmux copy binding currently uses Linux's `xclip`; replace it with `pbcopy`
before relying on mouse-copy in tmux on macOS.

Skills are kept in `skills/`. ChatGPT is optional. To install it and add a skill
later, run
`brew install --cask chatgpt`, then run
`ditto -c -k --norsrc --keepParent skills/<skill> ~/Desktop/<skill>.zip`.
In ChatGPT, choose **Plugins** > **Skills** > **Create** > **Upload** and select
that ZIP.
