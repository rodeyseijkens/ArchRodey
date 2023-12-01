#!/bin/bash

echo -ne "
-------------------------------------------------------------------------
               Installing Flatpak Packages
-------------------------------------------------------------------------
"
# List of packages to install
packages=(
  com.discordapp.Discord
  com.github.tchx84.Flatseal
  com.mattjakeman.ExtensionManager
  com.spotify.Client
  com.valvesoftware.Steam
  com.valvesoftware.Steam.CompatibilityTool.Boxtron
  com.valvesoftware.Steam.Utility.gamescope
  com.valvesoftware.Steam.Utility.protontricks
  com.valvesoftware.SteamLink
  io.github.flattool.Warehouse
  org.gnome.Boxes
  org.mozilla.firefox
  org.telegram.desktop
)

# Install each package
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
for package in "${packages[@]}"
do
  echo "INSTALLING: $package"
  flatpak install flathub "$package" --assumeyes --noninteractive
done

echo -ne "
-------------------------------------------------------------------------
               Installing Custom Theming
-------------------------------------------------------------------------
"
# Check if the OS is gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # Gnome Theme for Firefox
  curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
fi

echo -ne "
-------------------------------------------------------------------------
               Misc. Configurations
-------------------------------------------------------------------------
"
echo "Fixing Firefox font rendering"
mkdir -p $HOME/.var/app/org.mozilla.firefox/config/fontconfig/
mv $HOME/.config/autostart/data/fonts.conf $HOME/.var/app/org.mozilla.firefox/config/fontconfig/

echo "Setting Nautilus as default file manager"
xdg-mime default org.gnome.Nautilus.desktop inode/directory

echo "Installing powerlevel10k theme for zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.config/oh-my-zsh/themes/powerlevel10k

echo "Installing zsh files and setting zsh as default shell"
cp -r $HOME/.config/autostart/data/* $HOME/
chsh -s $(which zsh)

echo -ne "
-------------------------------------------------------------------------
               Completed installation
-------------------------------------------------------------------------
"
# Auto delete this current script after installation
rm -- $HOME/.config/autostart/first-boot.desktop
rm -- $HOME/.config/autostart/first-boot.sh
rm -rf $HOME/.config/autostart/data