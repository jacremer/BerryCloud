#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
apt-get update && apt-get upgrade -y && apt-get install -f
apt-get install nano sudo lvm2 parted ntp ntpdate miredo miniupnpc aptitude dialog figlet zip unzip landscape-common ufw linux-firmware openssh-server curl samba tar wget rsync software-properties-common update-manager update-notifier rsyslog

# Install packages for Webmin
apt-get install --force-yes -y zip perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python

# Install Webmin
echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" > /etc/apt/sources.list
cd /root
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
cd
apt-get update
apt-get install webmin
sed -i 's|gray-theme|authentic-theme|g' /etc/webmin/config
sed -i 's|gray-theme|authentic-theme|g' /etc/webmin/miniserv.conf
service webmin restart
echo
echo "Webmin is installed, access it from your browser: https://$ADDRESS:10000"
sleep 3

# libre office
echo -ne '\n' | sudo add-apt-repository ppa:libreoffice/libreoffice-4-4
apt-get update
apt-get install --no-install-recommends libreoffice-writer -y

# ssh locales fix

# mDns
apt-get install mdns

# Modify /etc/hosts
echo "127.0.0.1 localhost" >> /etc/hosts
echo "127.0.1.1 owncloud" >> /etc/hosts

# Set swappiness
echo "vm.swappiness = 10" > /etc/sysctl.conf

# Remove users
userdel ezra
userdel 

# add user
adduser ocadmin
usermod -aG sudo ocadmin

# boot.ini root=dev rw
