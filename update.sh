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
cat <<-UPDATE > "/etc/cron.daily/update_checker_cron.sh"
#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
# note for devs: change version numbers in techandme.se, update.sh and update_checker.sh for this script to work.
# If techandme.sh contains version number below, then a old version is detected and install a newer version
# Check versions
grep -rhln "1.2" /var/scripts/techandme.sh
if [[ $? > 0 ]]
        then
                exit 0
         else
sudo wget https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/update.sh -P /var/scripts/
sudo chmod 750 /var/scripts/update.sh
sudo bash /var/scripts/update.sh
fi

mesg n
UPDATE
chmod 750 /etc/cron.daily/rpi-update.sh

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
echo "sudo rpi-update" >> /etc/cron.weekly/rpi-update.sh
chmod 755 /etc/cron.weekly/rpi-update.sh
rpi-update

# Get the latest login screen
rm /var/scripts/techandme.sh
wget https://github.com/ezraholm50/BerryCloud/raw/master/techandme.sh -P /var/scripts/
chown ocadmin:ocadmin /var/scripts/techandme.sh
chmod 750 /var/scripts/techandme.sh

# Cleanup
rm /var/scripts/update.sh
apt-get autoclean -y && apt-get autoremove -y && apt-get update && apt-get upgrade -y
reboot

##################################################################################################################################################
##Version 1.3

exit 0
