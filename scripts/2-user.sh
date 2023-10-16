#!/usr/bin/env bash
#github-action genshdoc
#
# @file User
# @brief User customizations and AUR package installation.
echo -ne "
-------------------------------------------------------------------------
 █████╗ ██████╗  ██████╗██╗  ██╗██████╗  ██████╗ ██████╗ ███████╗██╗   ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔════╝╚██╗ ██╔╝
███████║██████╔╝██║     ███████║██████╔╝██║   ██║██║  ██║█████╗   ╚████╔╝ 
██╔══██║██╔══██╗██║     ██╔══██║██╔══██╗██║   ██║██║  ██║██╔══╝    ╚██╔╝  
██║  ██║██║  ██║╚██████╗██║  ██║██║  ██║╚██████╔╝██████╔╝███████╗   ██║   
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝             
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: ArchRodey
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/ArchRodey/configs/setup.conf

sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchRodey/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done


if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchRodey/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done


  ## If file exists, install AUR packages
  if [[ -f ~/ArchRodey/pkg-files/aur-pkgs-${DESKTOP_ENV}.txt ]]; then
    # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
    # stop the script and move on, not installing any more packages below that line
    sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchRodey/pkg-files/aur-pkgs-${DESKTOP_ENV}.txt | while read line
    do
      if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
        # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
        continue
      fi
      echo "INSTALLING: ${line}"
      $AUR_HELPER -S --noconfirm --needed ${line}
    done
  fi
fi

export PATH=$PATH:~/.local/bin

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
