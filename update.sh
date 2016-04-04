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
      		rm /etc/cron.daily/update_checker_cron.sh      	else
      		sleep 1
fi

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
wget https://raw.githubusercontent.com/ezraholm50/BerryCloud/master/update.sh -P /var/scripts/
chmod 750 /var/scripts/update.sh
bash /var/scripts/update.sh
fi

mesg n
UPDATE
chmod 750 /etc/cron.daily/update_checker_cron.sh

# Get the latest update checker daily
echo "rm /var/scripts/update_checker.sh" >> /etc/cron.daily/fresh_update_checker.sh
echo "wget https://github.com/ezraholm50/BerryCloud/raw/master/update_checker.sh -P /var/scripts/" > /etc/cron.daily/fresh_update_checker.sh
chmod 750 /etc/cron.daily/fresh_update_checker.sh

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
