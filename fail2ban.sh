#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
HTML=/var/www
OCPATH=$HTML/owncloud
DATA=/$OCPATH/data

# install fail2ban
#wget http://archive.ubuntu.com/ubuntu/pool/universe/f/fail2ban/fail2ban_0.9.3.orig.tar.gz -P /tmp/
#tar xzf /tmp/fail2ban_0.9.3.orig.tar.gz
#mv /tmp/fail2ban-0.9.3 /etc/fail2ban
#cd /etc/fail2ban && python setup.py install
#cd
apt-get update
apt-get install fail2ban -y

# Setup fail2ban
sudo -u www-data php $OCPATH/occ config:system:set loglevel --value="2"
sudo -u www-data php $OCPATH/occ config:system:set logfile --value="$DATA/owncloud.log"

# Add fail2ban config
cat <<-FAIL2BAN-OWNCLOUD > "/etc/fail2ban/filter.d/owncloud.conf"
[Definition] failregex={"reqId":".*","remoteAddr":".*","app":"core","message":"Login failed: '.*' \(Remote IP: '<HOST>'\)","level":2,"time":".*"}
FAIL2BAN-OWNCLOUD

# Add fail2ban jail
cat <<-FAIL2BAN > "/etc/fail2ban/jail.local"
[owncloud]
enabled = true
filter  = owncloud
port    = https,http
bantime  = 3000
findtime = 600
maxretry = 4
logpath = $DATA/owncloud.log
FAIL2BAN

# Restart fail2ban
sudo service fail2ban restart

exit 0
