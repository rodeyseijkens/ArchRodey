#!/usr/bin/env bash
#github-action genshdoc
#
# @file Post-Setup
# @brief Finalizing installation configurations and cleaning up after script.
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

Final Setup and Configurations
GRUB EFI Bootloader Install & Check
"
source ${HOME}/ArchRodey/configs/setup.conf

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
-------------------------------------------------------------------------
               Creating (and Theming) Grub Boot Menu
-------------------------------------------------------------------------
"
# set kernel parameter for decrypting the drive
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
# set kernel parameter for adding splash screen
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

echo -e "Installing Grub configs..."
GRUB_TIMEOUT=0
echo -e "Backing up Grub config..."
cp -an /etc/default/grub /etc/default/grub.bak
echo -e "Setting timeout..."
echo "GRUB_TIMEOUT=\"${GRUB_TIMEOUT}\"" >> /etc/default/grub
echo -e "Updating grub..."
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Login Display Manager
-------------------------------------------------------------------------
"
if [[ ${DESKTOP_ENV} == "kde" ]]; then
  systemctl enable sddm.service
  if [[ ${INSTALL_TYPE} == "FULL" ]]; then
    echo [Theme] >>  /etc/sddm.conf
    echo Current=Nordic >> /etc/sddm.conf
  fi

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  systemctl enable gdm.service

else
  if [[ ! "${DESKTOP_ENV}" == "server"  ]]; then
  sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service
  fi
fi


echo -ne "
-------------------------------------------------------------------------
               Theming and DE specific Configurations
-------------------------------------------------------------------------
"
if [[ ${DESKTOP_ENV} == "kde" ]]; then
  if [[ ${INSTALL_TYPE} == "FULL" ]]; then
    echo [Theme] >>  /etc/sddm.conf
    echo Current=Nordic >> /etc/sddm.conf

    cp -r ~/ArchRodey/configs/.config/* ~/.config/
    pip install konsave
    konsave -i ~/ArchRodey/configs/kde.knsv
    sleep 1
    konsave -a kde
  fi

elif [[ "${DESKTOP_ENV}" == "gnome" ]]; then
  if [[ ${INSTALL_TYPE} == "FULL" ]]; then
    # Default dconf settings
    cp -r ~/ArchRodey/configs/etc/donf/* /etc/dconf/
    dconf update

    # Gnome Theme for Firefox
    curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
  fi
fi

echo -ne "
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
"
systemctl enable cups.service
echo "  Cups enabled"
ntpd -qg
systemctl enable ntpd.service
echo "  NTP enabled"
systemctl disable dhcpcd.service
echo "  DHCP disabled"
systemctl stop dhcpcd.service
echo "  DHCP stopped"
systemctl enable NetworkManager.service
echo "  NetworkManager enabled"
systemctl enable bluetooth
echo "  Bluetooth enabled"
systemctl enable avahi-daemon.service
echo "  Avahi enabled"

echo -ne "
-------------------------------------------------------------------------
               Installing Flatpak Packages
-------------------------------------------------------------------------
"
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchRodey/pkg-files/flatpak-pkgs.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  flatpak install flathub ${line} --user --assumeyes --noninteractive
done

echo -ne "
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r $HOME/ArchRodey
rm -r /home/$USERNAME/ArchRodey

# Replace in the same state
cd $pwd
