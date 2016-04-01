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
echo "  BerryCloud ownCloud server VERSION 1.0"
echo -e "\e[32m"###################################################################"\e[0m"
echo "WAN IP:   type: WAN"
echo "LAN IP:   $ADDRESS"
echo "MAC ADR:  $MAC"
echo "Webmin:   https://$ADDRESS:10000"
echo "ownCloud: https://$ADDRESS/owncloud"
echo -e "\e[32m"###################################################################"\e[0m"
bash $DIR/50-landscape-sysinfo
echo -e "\e[32m"###################################################################"\e[0m"
bash $DIR/90-updates-available
bash $DIR/91-release-upgrade
bash $DIR/98-fsck-at-reboot
bash $DIR/98-reboot-required
exit 0
