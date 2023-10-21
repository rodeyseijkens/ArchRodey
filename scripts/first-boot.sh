#!/bin/bash

# Redirect standard output and standard error to the log file
exec &>> "~/first-boot.log"

echo -ne "
-------------------------------------------------------------------------
               Installing Flatpak Packages
-------------------------------------------------------------------------
"
# List of packages to install
packages=(
  com.discordapp.Discord
  com.gitub.tchx84.Flatseal
  com.mattjakeman.ExtensionManager
  com.spotify.Client
  com.valvesoftware.Steam
  io.github.flattool.Warehouse
  org.gnome.Boxes
  org.mozilla.firefox
  org.telegram.desktop
)

# Install each package
for package in "${packages[@]}"
do
  echo "INSTALLING: $package"
  flatpak install flathub "$package" --user --assumeyes --noninteractive
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
               Completed installation
-------------------------------------------------------------------------
"
# Auto delete this current script after installation
rm -- "$0"