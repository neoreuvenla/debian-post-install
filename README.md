<img src="https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white">

# Debian Post-Install Configuration Script

This repository contains a script to automate the system configuration of a fresh Macbook Pro (2015) Debian 12 (Bookworm) installation. 

It facilitates a largely unattended installation, only requiring interaction regarding theme installs. 

As this is intended for personal use only, no support is planned. Use at your own risk.

## Prerequisites

Prior to running the script, `git` needs to be installed on the Debian system to clone this repository.

### Installing Git

Open the terminal and run the following command:

```
sudo apt update
sudo apt install -y git
```

## Cloning the Repository

With `git` installed, the repository can be cloned to the local machine by running the following command in the terminal:

```
git clone https://github.com/neoreuvenla/debian-post-install.git
cd debian-post-install
```

## Running the Script

Before running the script, make sure it is executable:

```
chmod +x setup-debian.sh
```

The script can then be run with administrative privileges:

```
sudo ./setup-debian.sh
```

Follow the on-screen prompts to complete the installations and configurations. The script will pause for input regarding the optional installation of the BigSur emulating theme.

## What the Script Does

Broadly, the script:

* Disables CDROM source: prevents the system from using the CDROM as an installation source
* Adds and configures repositories: configures necessary Debian and third-party repositories for packages and updates
* Installs essential and utility software: installs basic tools and utilities like Flatpak, Broadcom WiFi drivers, Synaptic, etc...
* Configures system services: sets up system services like tlp for power management and powertop for power consumption monitoring
* Installs themes and customization: optionally installs the BigSur like theme and other aesthetic enhancements
* Cleans up the system: removes unnecessary packages and performs system cleanup