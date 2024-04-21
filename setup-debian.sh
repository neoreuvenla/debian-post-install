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
sudo apt install -y zram-tools
echo -e "ALGO=zstd\nPERCENT=60" | sudo tee -a /etc/default/zramswap
sudo service zramswap reload
sudo swapon -p 10 /dev/sda3

# MULLVAD
sudo apt install curl
sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
sudo apt update
sudo apt install -y mullvad-vpn


# OPTIONAL BIGSUR THEMING (https://github.com/jothi-prasath/SmallSur)
echo "Do you want to install the BigSur theme? (y/n)"
read response
response=${response,,}  # Converts to lowercase
if [[ "$response" == "y" ]]; then
echo "Installing theme..."
    sudo apt install -y plank ulancher vala-panel-appmenu
    user_name="$USER"
    sudo apt install xfce4-appmenu-plugin appmenu-* -y
    sudo apt install xfce4-indicator-plugin xfce4-statusnotifier-plugin xfce4-power-manager xfce4-pulseaudio-plugin xfce4-notifyd -y
    git clone https://github.com/jothi-prasath/WhiteSur-gtk-theme.git --depth=1
    WhiteSur-gtk-theme/install.sh -l -c dark -c light
    rm -rf WhiteSur-gtk-theme
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git --depth=1
    WhiteSur-icon-theme/install.sh
    rm -rf WhiteSur-icon-theme
    git clone https://github.com/vinceliuice/WhiteSur-cursors.git --depth=1
    mkdir -p ~/.local/share/icons/
    cp -r WhiteSur-cursors/dist/ ~/.local/share/icons/
    rm -rf WhiteSur-cursors
    mkdir -p ~/Pictures/
    cp -r wallpaper/* ~/Pictures/
    mkdir -p ~/.local/share/plank/themes/
    cp -rp WhiteSur-gtk-theme/src/other/plank/* ~/.local/share/plank/themes/
    cp -rp plank/mcOS-BS-iMacM1-Black/ ~/.local/share/plank/themes/
    sudo killall xfce4-panel 
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -rp xfce4-panel/xfce4-panel.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    xfconf-query -c xsettings -p /Net/ThemeName -s "WhiteSur-dark" 
    xfconf-query -c xsettings -p /Net/IconThemeName -s 'WhiteSur-dark' 
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "WhiteSur Cursors" 
    echo "SmallSur installed, reboot advised"

else
    echo "Skipping theme..."
fi

# SYSTEM CLEANUP
sudo apt remove --purge -y xterm xfce4-dict xfburn hv3 xsane
sudo apt autoremove -y
