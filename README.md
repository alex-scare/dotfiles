
#### About configuration files 

- Common configs: `zsh`, `tmux`, `ghostty`, `starship`, `nvim`
- Arch only: `hyprland`, `waybar`
- MacOS only: `aerospace`, `sketchybar`

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
