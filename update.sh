##################################################################################################################################################
# Version 1.2
# Check if root
        if [ "$(whoami)" != "root" ]; then
        echo
        echo -e "\e[31mSorry, you are not root.\n\e[0mYou must type: \e[36msudo \e[0mbash /var/scripts/update.sh"
        echo
        exit 1
fi

# Upgrade and install
apt-get update && apt-get upgrade -y && apt-get -f install -y
apt-get install rsyslog systemd module-init-tools -y
dpkg --configure --pending

# Add update checker to daily cron

if 		[ -f /etc/cron.daily/update_checker_cron.sh ];
	then
      		rm /etc/cron.daily/update_checker_cron.sh
      	else
      		sleep 1
fi

# Get the latest update checker daily
echo "rm /var/scripts/update_checker.sh" >> /etc/cron.daily/fresh_update_checker.sh
echo "wget https://github.com/ezraholm50/BerryCloud/raw/master/update_checker.sh -P /var/scripts/" > /etc/cron.daily/fresh_update_checker.sh
chmod 750 /etc/cron.daily/fresh_update_checker.sh

# Install rpi-update
echo "deb http://archive.raspberrypi.org/debian/ jessie main" > /etc/apt/sources.list
wget "http://archive.raspberrypi.org/debian/raspberrypi.gpg.key"
apt-key add raspberrypi.gpg.key
apt-get update
apt-get install libraspberrypi-bin -y
curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update && sudo chmod +x /usr/bin/rpi-update
# Make sure rpi-config doesnt use the wrong repo's
cat <<-UPDATE > "/etc/cron.weekly/rpi_update.sh"
#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
rpi-update
rm /etc/apt/sources.list
cat <<-SOURCES > "/etc/apt/sources.list"
# Tech and Me, 2016 - www.techandme.se
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.

deb http://ports.ubuntu.com/ubuntu-ports/ vivid main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://ports.ubuntu.com/ubuntu-ports/ vivid-updates main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-updates main restricted

## Uncomment the following two lines to add software from the 'universe'
## repository.
## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid universe
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-updates universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-updates universe

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-backports main restricted
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-backports main restricted

deb http://ports.ubuntu.com/ubuntu-ports/ vivid-security main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-security main restricted
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-security universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-security universe
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-security multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-security multiverse
SOURCES

UPDATE
rpi-update
chmod 750 /etc/cron.daily/rpi-update.sh
rm /etc/apt/sources.list
cat <<-SOURCES > "/etc/apt/sources.list"
# Tech and Me, 2016 - www.techandme.se
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.

deb http://ports.ubuntu.com/ubuntu-ports/ vivid main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://ports.ubuntu.com/ubuntu-ports/ vivid-updates main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-updates main restricted

## Uncomment the following two lines to add software from the 'universe'
## repository.
## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid universe
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-updates universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-updates universe

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-backports main restricted
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-backports main restricted

deb http://ports.ubuntu.com/ubuntu-ports/ vivid-security main restricted
deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-security main restricted
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-security universe
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-security universe
# deb http://ports.ubuntu.com/ubuntu-ports/ vivid-security multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ vivid-security multiverse
SOURCES

# Get the latest login screen
rm /var/scripts/techandme.sh
wget https://github.com/ezraholm50/BerryCloud/raw/master/techandme.sh -P /var/scripts/
chown ocadmin:ocadmin /var/scripts/techandme.sh
chmod 750 /var/scripts/techandme.sh

# Cleanup
echo "" > /etc/apt/sources.list
echo "" > /etc/apt/sources.list

rm /var/scripts/update.sh
apt-get autoclean -y && apt-get autoremove -y && apt-get update && apt-get upgrade -y
reboot

##################################################################################################################################################
##Version 1.3

exit 0
