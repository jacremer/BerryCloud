#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
USERNAME='ocadmin'
USERPASS='owncloud'
device='/dev/mmcblk0'
ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')
SCRIPTS='/var/scripts'
##################################################################################################################################################
# Version 1.2 Update
# Check if root
        if [ "$(whoami)" != "root" ]; then
        echo
        echo -e "\e[31mSorry, you are not root.\n\e[0mYou must type: \e[36msudo \e[0mbash /var/scripts/update.sh"
        echo
        exit 1
fi

# Upgrade and install
apt-get update && apt-get upgrade -y && apt-get -f install -y
apt-get install systemd rsyslog module-init-tools miredo libminiupnpc10 ntpdate landscape-common -y
dpkg --configure --pending

# Libreoffice
apt-get install --no-install-recommends libreoffice-writer -y

# Install packages for Webmin
apt-get install -y zip perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python

# Install Webmin
echo 'deb http://download.webmin.com/download/repository sarge contrib' >> /etc/apt/sources.list
wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
apt-get update
apt-get install -y webmin
echo
echo "Webmin is installed, access it from your browser: https://$ADDRESS:10000"
sleep 2
clear

# Add update checker to daily cron

if 		[ -f /etc/cron.daily/update_checker_cron.sh ];
	then
      		rm /etc/cron.daily/update_checker_cron.sh
      	else
      		sleep 1
fi

# Get the latest update checker daily
#echo "rm /var/scripts/update_checker.sh" >> /etc/cron.daily/fresh_update_checker.sh
#echo "wget https://github.com/ezraholm50/BerryCloud/raw/master/update_checker.sh -P /var/scripts/" > /etc/cron.daily/fresh_update_checker.sh
#chmod 750 /etc/cron.daily/fresh_update_checker.sh

# Backup sources
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Install rpi-update
echo "deb http://archive.raspberrypi.org/debian/ jessie main" > /etc/apt/sources.list
wget "http://archive.raspberrypi.org/debian/raspberrypi.gpg.key"
apt-key add raspberrypi.gpg.key
apt-get update
apt-get install libraspberrypi-bin -y
curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update
rpi-update

# Restore sources
cp /etc/apt/sources.list.bak /etc/apt/sources.list
apt-get update

# Get the latest login screen
rm /var/scripts/techandme.sh
wget https://github.com/ezraholm50/BerryCloud/raw/master/techandme.sh -P /var/scripts/
chown ocadmin:ocadmin /var/scripts/techandme.sh
chmod 750 /var/scripts/techandme.sh

# Cleanup
rm /var/scripts/update.sh
apt-get autoclean -y && apt-get autoremove -y && apt-get update && apt-get upgrade -y
dpkg --configure --pending

# Ask if user has an RPI2 or #
#bash $SCRIPTS/rpi_version.sh

# Set ownership to parts of the welcome screen
chown :ocadmin /etc/update-motd.d/*

# Get Script to show WAN IP and set alias cmd to WAN
wget -q https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/wan.sh -P /home/ocadmin/
echo 'alias WAN="sudo bash /home/ocadmin/wan.sh"' > /home/ocadmin/.bashrc
echo 'alias WAN="bash /home/ocadmin/wan.sh"' > /root/.bashrc
chmod 750 /home/ocadmin/wan.sh
chown ocadmin:root /home/ocadmin/wan.sh

# Set hostname and ServerName
hostnamectl set-hostname owncloud 
#echo "127.0.0.1 localhost" >> /etc/hosts
#echo "127.0.1.1 owncloud" >> /etc/hosts

# Set locales
sudo locale-gen "en_US.UTF-8" && sudo dpkg-reconfigure locales

# Set keyboard layout
echo "Current keyboard layout is English"
echo "You must change keyboard layout to your language"
echo -e "\e[32m"
read -p "Press any key to change keyboard layout... " -n1 -s
echo -e "\e[0m"
dpkg-reconfigure keyboard-configuration
echo
clear

# Change Timezone
echo "Current Timezone is Europe/Amsterdam"
echo "You must change timezone to your timezone"
echo -e "\e[32m"
read -p "Press any key to change timezone... " -n1 -s
echo -e "\e[0m"
dpkg-reconfigure tzdata
echo
sleep 3
clear

# Change login scripts
sed -i 's|#bash /var/scripts/instructions.sh|bash /var/scripts/instructions.sh|g' /home/ocadmin/.profile
sed -i 's|bash /var/scripts/pre_setup_message.sh|#bash /var/scripts/pre_setup_message.sh|g' /home/ocadmin/.profile

# Change back root/.profile
ROOT_PROFILE="/root/.profile"
rm /root/.profile
cat <<-ROOT-PROFILE > "$ROOT_PROFILE"
# ~/.profile: executed by Bourne-compatible login shells.
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
if [ -x /var/scripts/setup.sh ]; then
        /var/scripts/setup.sh
fi
if [ -x /var/scripts/history.sh ]; then
        /var/scripts/history.sh
fi
mesg n
ROOT-PROFILE

# Change back rc.local
rm /etc/rc.local

cat << RCLOCAL > "/etc/rc.local"
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0

RCLOCAL

# Set permissions for rc.local
chmod 755 /etc/rc.local

# Use external harddrive to mount os and sd card to boot
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Do you have an external Harddisk plugged in? (Recommended, SSD, powered external drive) ALL DATA WILL BE LOST AFTER THE FORMAT") ]]
then
echo
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Is the harddisk bigger then 2TB?") ]]
then
wget -q https://github.com/ezraholm50/BerryCloud/raw/master/gpt_usb.sh -P $SCRIPTS/
bash $SCRIPTS/gpt_usb.sh
else
bash $SCRIPTS/external_usb.sh
fi

else
        # Want to do this later? 
echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| Ok, you have chosen to not use an external HD/SSD                  |"
echo    "| This is not only a performance limitation but it could             |"
echo    "| Also mean that your Micro SDCard could die soon because            |"
echo    "| Of the intense writing to the SDCard.                              |"
echo    "|                                                                    |"
echo    "| If you do want to use a Harddisk run:                              |"
echo    "|                         sudo bash /var/scripts/external_usb.sh     |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to continue..." -n1 -s
echo -e "\e[0m"
echo

# Resize sd card
fdisk $device << EOF
d
2
w
EOF
sync

fdisk $device << EOF
n
p
2


w
EOF
sync
partprobe

# Install swapfile of 2 GB
if 		[ -f /swapfile ];
	then
      		sleep 1
      	else
      		fallocate -l 2048M /swapfile # create swapfile and set size
      		chmod 600 /swapfile # give it the right permissions
      		mkswap /swapfile # format as swap
      		swapon /swapfile # announce to system
      		echo "/swapfile none swap defaults 0 0" >> /etc/fstab # let the system know what file to use as swap after reboot
fi

clear

# Success!
echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| Your ip is $ADDRESS ssh is installed so you could disconnect your  |"
echo    "| Monitor and continue the installation over ssh, after the reboot.  |"
echo    "| After this reboot log back in with ocadmin///owncloud              |"
echo    "| The installation will then automatically begin.                    |"
echo    "|                                                                    |"
echo    "|                        ***SSH***                                   |"
echo    "| 1. Open a terminal on laptop/desktop (ctrl + alt + T for linux)    |"
echo    "| 2. Execute the command: sudo apt-get install openssh-client        |"
echo    "| 3. Execute the command: ssh -l ocadmin $ADDRESS                    |"
echo    "| 4. Type password: owncloud                                         |"
echo    "| 5. Follow the instructions                                         |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to continue..." -n1 -s
echo -e "\e[0m"
echo
clear

fi

# Reboot
reboot

exit 0
