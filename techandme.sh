#!/bin/bash
ADDRESS=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
DIR='/etc/update-motd.d'
MAC=$(ifconfig | grep HWaddr | awk '{ print $5 }')
clear
figlet BerryCloud
figlet -f small Tech and Me
echo "           https://www.techandme.se"
echo -e "\e[32m"###################################################################"\e[0m"
bash $DIR/00-header
echo "  BerryCloud ownCloud server VERSION 1.2"
echo -e "\e[32m"###################################################################"\e[0m"
echo "WAN IP:   type: sudo WAN"
echo "LAN IP:   $ADDRESS"
echo "MAC ADR:  $MAC"
echo "Webmin:   https://$ADDRESS:10000"
echo "ownCloud: https://$ADDRESS"
echo -e "\e[32m"###################################################################"\e[0m"
bash $DIR/50-landscape-sysinfo
echo -e "\e[32m"###################################################################"\e[0m"
bash /var/scripts/update_checker.sh
bash $DIR/90-updates-available
## Remove this on fix
echo "Please read https://github.com/ezraholm50/BerryCloud/wiki/a-Update-Ubuntu-15.10-to-16.04 if you want to upgrade to 16.04!"
bash $DIR/91-release-upgrade
bash $DIR/98-fsck-at-reboot
bash $DIR/98-reboot-required
# Fix for fail2ban, security issue, doesnt log failed attempts, cant wait so thats why its not on regular update. Autoremoves when ran.
sudo sed -i 's|/owncloud/data|/var/www/owncloud/data|g' /etc/fail2ban/jail.local
sudo sed -i "s|sudo sed -i 's|/owncloud/data|/var/www/owncloud/data|g' /etc/fail2ban/jail.local||g" /var/scripts/techandme.sh
sudo sed -i "s|sudo sed -i 's|# Fix for fail2ban, security issue, doesnt log failed attempts, cant wait so thats why its not on regular update. Autoremoves when ran.||g" /var/scripts/techandme.sh
exit 0
