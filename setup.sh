#!/bin/bash

## SOURCES AND REPOS ##

# DISABLE CDROM SOURCE
sudo sed -i 's/^\s*deb cdrom:/#deb cdrom:/' /etc/apt/sources.list

# ENABLE DEBIAN BACKPORT REPO
echo "deb http://deb.debian.org/debian bookworm-backports main" | sudo tee -a /etc/apt/sources.list.d/backports.list
sudo apt update
# sudo apt -t bookworm-backports install <package-name> # for future use

# ADD CONTRIB AND NON-FREE REPOS
echo "deb http://deb.debian.org/debian bookworm main contrib non-free" | sudo tee /etc/apt/sources.list.d/debian-contrib-non-free.list
echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free" | sudo tee -a /etc/apt/sources.list.d/debian-contrib-non-free.list
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free" | sudo tee -a /etc/apt/sources.list.d/debian-contrib-non-free.list
sudo apt update

# FLATPAK REPOS
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo apt update


## SYSTEM UPDATE ##

# UPDATE SYSTEM
sudo apt update
sudo apt dist-upgrade


## APPLICATIONS

# BROADCOM WIFI (likely already installed but here for completeness)
sudo apt install -y firmware-brcm80211

# SYNAPTIC (likely already installed but here for completeness)
sudo apt install -y synaptic

# NANO (likely already installed but here for completeness)
sudo apt install nano

# GIT (installed if following the readme instructions)
sudo apt install -y git

# REPLACE FIREFOX ESR WITH MOZILLA REPO FIREFOX
sudo apt remove -y firefox-esr
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt/debian/ bookworm firefox" | sudo tee /etc/apt/sources.list.d/mozilla-firefox.list
echo "Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000" | sudo tee /etc/apt/preferences.d/mozilla-firefox
sudo apt update && sudo apt install -y firefox

# SIGNAL
wget -qO- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg >/dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list
sudo apt update && sudo apt install -y signal-desktop

# LIBREOFFICE (uncomment to remove .deb and install flatpak version)
# sudo apt remove --purge -y libreoffice*
# sudo apt autoremove -y
# sudo flatpak install -y flathub org.libreoffice.LibreOffice

# MULTIMEDIA CODECS
sudo apt install libavcodec-extra

# TLP
sudo apt install -y tlp
sudo systemctl enable tlp
sudo systemctl start tlp

# POWERTOP
sudo apt install -y powertop
sudo powertop --calibrate
echo -e '[Unit]\nDescription=PowerTOP auto-tune\n[Service]\nType=oneshot\nExecStart=/usr/sbin/powertop --auto-tune\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/powertop.service
sudo systemctl enable powertop.service
sudo systemctl start powertop.service

# UFW
sudo apt install ufw -y
echo 'yes' | sudo ufw enable
sudo ufw default deny incoming

# MBPFAN (Macbook Pro Fans)
sudo apt install mbpfan -y 
sudo systemctl enable mbpfan 
sudo systemctl start mbpfan
echo "min_fan_speed = 2000  # Minimum fan speed" | sudo tee -a /etc/mbpfan.conf
sudo systemctl restart mbpfan

# GEARY
sudo apt install -y geary

# PLYMOUTH (with darwin boot theme)
sudo apt install -y plymouth
git clone https://github.com/libredeb/darwin-plymouth
sudo cp -R darwin/ /usr/share/plymouth/themes/
sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/darwin/darwin.plymouth 100
sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/darwin/darwin.plymouth
GRUB_CMDLINE="quiet splash"
sudo sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_CMDLINE\"/" /etc/default/grub
sudo update-grub
sudo update-initramfs -u

# ZRAM
sudo apt install zram-tools -y
echo -e "ALGO=zstd\nPERCENT=60" | sudo tee -a /etc/default/zramswap
sudo service zramswap reload
sudo swapon -p 10 /dev/sda3

# MULLVAD
sudo apt install curl
sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
sudo apt update
sudo apt install -y mullvad-vpn

# THEMING



# SYSTEM CLEANUP
sudo apt remove --purge -y xterm xfce4-dict xfburn hv3 xsane
sudo apt autoremove -y
