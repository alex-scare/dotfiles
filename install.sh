
##### Basic functionality

pacman -S --noconfirm networkmanager wget base-devel stow

##### Prepare terminal

pacman -S --noconfirm ghostty neovim zsh 

##### Prepare hyprland

pacman -S --noconfirm hyprland hyprpaper waybar 

##### Fix nvidia drivers

pacman -S --noconfirm nvidia-settings nvidia-utils nvidia-open-dkms gamemode linux-headers

##### Install usefull stuff

pacman -S --noconfirm proton-vpn-gtk-app 
yay -Sy brave-bin

##### stow configs

stow nvim
stow hyprland
