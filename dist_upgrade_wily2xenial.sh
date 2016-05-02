#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
sed -i -e "s/wily/xenial/g" /etc/apt/sources.list
apt-get update && apt-get dist-upgrade
apt-get autoremove --purge -y;apt-get clean
reboot
exit 0
